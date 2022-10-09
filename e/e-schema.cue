package env

// Each environment is hosted on a Kubernetes machine.  
// The machine's name is set to the env key.
// ApplicationSets configure what applications are run.
env: [NAME=string]: (#K3D | #VCluster) & {
	name: NAME
}

// Applications configured in an ApplicationSet
#AppSetElement: {
	name:    string
	path:    string | *name
	cluster: string

	_has_namespace: bool
	namespace?:     string
	if _has_namespace {
		namespace: string | *name
	}
}

// ApplicationSet configured in a Machine
#AppSet: {
	_name:      string
	_prefix:    string | *""
	_suffix:    string | *""
	_namespace: bool | *true
	_prune:     bool | *false
	_apps: [...#AppSetElement]

	apiVersion: "argoproj.io/v1alpha1"
	kind:       "ApplicationSet"

	metadata: {
		name:      "\(_prefix)\(_name)\(_suffix)"
		namespace: "argocd"
	}

	_ai_cluster: {
		if _name == "control" {
			cluster: "in-cluster"
		}
		if _name != "control" {
			cluster: "\(_prefix)\(_name)"
		}
	}
	_ai: _ai_cluster & {_has_namespace: _namespace}

	spec: generators: [{
		list: {
			elements: [..._ai]
			elements: _apps
		}
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

// Application for a Machine's ApplicationSets
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

// Application for a Vcluster
#VClusterApp: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      string
		namespace: "argocd"
	}
	spec: {
		project: "default"
		source: {
			repoURL:        "https://github.com/defn/app"
			path:           string
			targetRevision: "master"
		}
		destination: {
			namespace: string
			name:      "in-cluster"
		}
		syncPolicy: syncOptions: ["CreateNamespace=true"]
	}
}

// Machines run ApplicationSets
#Machine: {
	type: string
	name: string

	env: #EnvApp

	appset: [string]: #AppSet & {
		_name: name
	}
}

// K3D Machine
#K3D: ctx={
	#Machine
	type: "k3d"

	env: {
		metadata: name: "k3d-\(ctx.name)"

		spec: source: path: "e/k3d-\(ctx.name)"

		spec: syncPolicy: automated: prune: true
	}

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

// VCluster Machine
#VCluster: ctx={
	#Machine
	type: "vcluster"

	k3d: #K3D

	env: {
		metadata: name: "\(k3d.env.metadata.name)-\(ctx.name)"

		spec: source: path: "e/\(ctx.name)"
	}

	vcluster: #VClusterApp & {
		metadata: name: "\(ctx.name)-vcluster"

		spec: source: path: "k/\(ctx.name)"

		spec: destination: namespace: ctx.name
	}
}
