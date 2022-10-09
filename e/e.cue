package env

#EnvApp: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"

	metadata: {
		namespace: "argocd"
		name:      string
	}

	spec: {
		project: "default"

		destination: name: "in-cluster"
		source: {
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"
			path:           string
		}

		syncPolicy?: automated?: prune?: bool
	}
}

#AppSetItem: {
	name:      string
	path:      string | *name
	cluster:   string
	namespace: string | *name
}

#AppSetItemNoNs: {
	name:    string
	path:    string | *name
	cluster: string
}

#AppSet: {
	_name:      string
	_prefix:    string | *""
	_suffix:    string | *""
	_namespace: bool | *true
	_prune:     bool | *false
	_apps: [...{...}]

	apiVersion: "argoproj.io/v1alpha1"
	kind:       "ApplicationSet"

	metadata: {...}
	metadata: {
		name:      "\(_prefix)\(_name)\(_suffix)"
		namespace: "argocd"
	}

	spec: {...}

	_appitemns: {
		if _name == "control" {
			cluster: "in-cluster"
		}
		if _name != "control" {
			cluster: "\(_prefix)\(_name)"
		}
	}
	_appitem: {
		if _namespace {
			#AppSetItem & _appitemns
		}
		if !_namespace {
			#AppSetItemNoNs & _appitemns
		}
	}

	spec: generators: [{
		list: elements: [..._appitem]
		list: elements: _apps
	}]

	spec: template: {
		metadata: {
			name:      "\(_prefix)\(_name)-{{name}}"
			namespace: "argocd"
		}

		spec: {
			project: "default"

			source: {
				repoURL:        "https://github.com/defn/app"
				path:           "k/{{path}}"
				targetRevision: "master"
			}

			destination: {
				if _namespace {
					namespace: "{{namespace}}"
				}
				name: "{{cluster}}"
			}

			syncPolicy: {
				syncOptions: [
					"CreateNamespace=true",
				]
				if _prune {
					automated: prune: true
				}
			}

			ignoreDifferences: [{
				kind:  "MutatingWebhookConfiguration"
				group: "admissionregistration.k8s.io"
				name:  "vault-agent-injector-cfg"
				jsonPointers: [
					"/webhooks/0/clientConfig/caBundle",
				]
			}, {
				kind:  "MutatingWebhookConfiguration"
				group: "admissionregistration.k8s.io"
				name:  "webhook.domainmapping.serving.knative.dev"
				jsonPointers: [
					"/webhooks/0/rules",
				]
			}, {
				kind:  "MutatingWebhookConfiguration"
				group: "admissionregistration.k8s.io"
				name:  "webhook.serving.knative.dev"
				jsonPointers: [
					"/webhooks/0/rules",
				]
			}, {
				kind:  "ValidatingWebhookConfiguration"
				group: "admissionregistration.k8s.io"
				name:  "validation.webhook.serving.knative.dev"
				jsonPointers: [
					"/webhooks/0/rules",
				]
			}, {
				kind:  "ValidatingWebhookConfiguration"
				group: "admissionregistration.k8s.io"
				name:  "validation.webhook.domainmapping.serving.knative.dev"
				jsonPointers: [
					"/webhooks/0/rules",
				]
			}, {
				kind:  "Deployment"
				group: "apps"
				name:  "kong-kong"
				jsonPointers: [
					"/spec/template/spec/tolerations",
				]
			}, {
				group: "kyverno.io"
				kind:  "ClusterPolicy"
				jqPathExpressions: [".spec.rules[] | select(.name|test(\"autogen-.\"))"]
			}]
		}
	}
}

#K3D: ctx={
	type: "k3d"
	name: string

	env: #EnvApp
	env: {
		metadata: {
			name: "k3d-\(ctx.name)"
		}

		spec: {
			source: path: "e/k3d-\(ctx.name)"

			syncPolicy: automated: prune: true
		}
	}

	appset: [string]: #AppSet
	appset: [NAME=string]: {
		_prefix: "k3d-"
		_prune:  true

		if NAME != "default" {
			_suffix: "-\(NAME)"
		}

		if NAME == "nons" {
			_namespace: false
		}
	}
}

#VCluster: ctx={
	type: "vcluster"
	name: string

	k3d: #K3D

	env: #EnvApp
	env: {
		metadata: {
			name: "\(k3d.env.metadata.name)-\(ctx.name)"
		}
		spec: {
			source: path: "e/\(ctx.name)"
		}
	}

	vcluster: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"
		metadata: {
			name:      "\(ctx.name)-vcluster"
			namespace: "argocd"
		}
		spec: {
			project: "default"
			source: {
				repoURL:        "https://github.com/defn/app"
				path:           "k/\(ctx.name)"
				targetRevision: "master"
			}
			destination: {
				namespace: ctx.name
				name:      "in-cluster"
			}
			syncPolicy: syncOptions: ["CreateNamespace=true"]
		}
	}

	appset?: [string]: #AppSet
}

env: [NAME=string]: name: NAME
env: [NAME=string]: appset: [string]: _name: NAME
env: [NAME=string]: appset: [string]: #AppSet
env: [NAME=string]: #K3D | #VCluster

env: control: #K3D & {
	appset: default: {
		_apps: [{
			name: "kyverno"
		}, {
			name: "cert-manager"
		}, {
			name: "external-secrets"
		}, {
			name: "argo-cd"
		}, {
			name: "argo-events"
		}, {
			name: "argo-workflows"
		}, {
			name: "knative"
		}]
	}

	appset: nons: {
		_apps: [{
			name: "kourier"
		}]
	}
}

env: circus: #K3D & {
	appset: default: {
		_apps: [{
			name: "kyverno"
		}, {
			name: "cert-manager"
		}, {
			name:      "kuma-global"
			namespace: "kuma"
		}]
	}
}

env: smiley: #K3D & {
	appset: default: {
		_apps: [{
			name: "kyverno"
		}, {
			name: "cert-manager"
		}]
	}
}

env: vc1: #VCluster & {
	k3d: env.control

	appset: default: {
		_apps: [{
			name:      "dev"
			namespace: "default"
		}]
	}
}

env: vc2: #VCluster & {
	k3d: env.control
}

env: vc3: #VCluster & {
	k3d: env.control
}

env: vc4: #VCluster & {
	k3d: env.control
}
