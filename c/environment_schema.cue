package c

import (
	"encoding/yaml"
)

// Each environment is hosted on a Kubernetes machine.  
// The machine's name is set to the env key.
env: [NAME=string]: (#K3D | #VCluster) & {
	name: NAME
}

bootstrap: [NAME=string]: #BootstrapMachine & {
	machine_name: NAME
}

for _machine_name, _machine in env {
	bootstrap: "\(_machine_name)": {
		machine_type: _machine.type
		apps:         _machine.bootstrap
	}

	kustomize: "\(_machine.type)-\(_machine_name)": #KustomizeHelm & {
		helm: {
			release: "bootstrap"
			name:    "any-resource"
			version: "0.1.0"
			repo:    "https://kiwigrid.github.io"
			values: {
				anyResources: {
					for _app_name, _app in bootstrap[_machine_name].out {
						"\(_app_name)": yaml.Marshal(_app.out)
					}
				}
			}
		}
	}
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

	spec: generators: [{
		_ai_cluster: {
			if _name == "control" {
				cluster: "in-cluster"
			}
			if _name != "control" {
				cluster: "\(_prefix)\(_name)"
			}
		}
		_ai: _ai_cluster & {_has_namespace: _namespace}

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

// Env Application to deploy ApplicationSets, VCluster Applications
#EnvAppSet: {
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

		syncPolicy: automated: prune: bool | *true
	}
}

// VCluster Application to deploy vcluster
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

	bootstrap: [string]: int

	env: #EnvAppSet

	env: {
		// ex: k/k3d-control
		// ex: k/vcluster-vc1-bootstrap
		spec: source: path: "e/\(type)-\(name)"

		spec: syncPolicy: automated: prune: true
	}

	apps: [string]: [string]: {...}

	appset: [string]: #AppSet & {
		_name: name
	}

	appset: {
		for _appset_name, _appset in apps {
			"\(_appset_name)": _apps: [
				for _app_name, _app in _appset {
					{name: _app_name} & _app
				},
			]
		}
	}
}

// K3D Machine
#K3D: ctx={
	#Machine
	type: "k3d"

	// ex: k3d-control
	env: metadata: name: "\(type)-\(ctx.name)"

	appset: [NAME=string]: {
		_prefix: "\(type)-"

		if NAME != "default" {
			_suffix: "-\(NAME)"
		}

		_prune: true

		if NAME == "nons" {
			_namespace: false
		}
	}
}

// VCluster Machine
#VCluster: ctx={
	#Machine
	type: "vcluster"

	machine: #K3D

	// ex: k3d-control-vc1
	env: metadata: name: "\(machine.env.metadata.name)-\(ctx.name)"

	vcluster: #VClusterApp & {
		// ex: vc1-vcluster
		metadata: name: "\(ctx.name)-vcluster"

		// ex: k/vcluster-vc1
		spec: source: path: "k/\(type)-\(ctx.name)"

		// ex: namespace: vc
		spec: destination: namespace: ctx.name
	}
}

#BootstrapApp: {
	machine_type: string
	machine_name: string
	app_name:     string
	app_wave:     int

	out: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"

		metadata: {
			namespace: "argocd"
			name:      "\(machine_type)-\(machine_name)-\(app_name)"
			annotations: "argocd.argoproj.io/sync-wave": "\(app_wave)"
		}

		spec: {
			project: "default"

			destination: name: "in-cluster"
			source: {
				repoURL:        "https://github.com/defn/app"
				targetRevision: "master"
				path:           "k/\(app_name)"
			}

			syncPolicy: automated: prune: true
		}
	}
}

#BootstrapMachine: ctx={
	machine_type: string
	machine_name: string

	apps: [string]: int

	out: [string]: #BootstrapApp
	out: {
		for _app_name, _app_weight in apps {
			"\(_app_name)": #BootstrapApp & {
				machine_type: ctx.machine_type
				machine_name: ctx.machine_name
				app_name:     _app_name
				app_wave:     _app_weight
			}
		}
	}
}
