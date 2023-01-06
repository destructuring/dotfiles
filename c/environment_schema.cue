package c

import (
	"encoding/yaml"
)

#EnvInput: {
	#Input
	type: string
	bootstrap: [string]: int
}

#TransformEnvToAnyResourceKustomizeHelm: {
	from: #EnvInput
	to:   #KustomizeHelm & {
		_in: #EnvInput

		_apps: (#TransformOne & {
			transform: #TransformEnvToBootstrap
			input:     _in
		}).output.apps

		helm: {
			release: "bootstrap"
			name:    "any-resource"
			version: "0.1.0"
			repo:    "https://kiwigrid.github.io"
			values: {
				anyResources: {
					for aname, a in _apps {
						"\(aname)": yaml.Marshal(a.application)
					}
				}
			}
		}
	}
}

#TransformEnvToSecretStoreKustomize: {
	from: #EnvInput
	to:   #Kustomize & {
		_in: #EnvInput

		resource: "cluster-secret-store-external-secrets": {
			apiVersion: "external-secrets.io/v1beta1"
			kind:       "ClusterSecretStore"
			metadata: name: "external-secrets"
			spec: provider: vault: {
				server:  "http://100.121.162.1:8200"
				path:    "kv"
				version: "v2"
				auth: kubernetes: {
					mountPath: "\(_in.type)-\(_in.name)"
					role:      "external-secrets"
				}
			}
		}
	}
}

#TransformEnvToBootstrap: {
	from: #EnvInput
	to:   #EnvBootstrap
}

#EnvBootstrap: ctx={
	_in: #EnvInput

	machine_name: string | *_in.name
	machine_type: string | *_in.type

	apps: [string]: #EnvBootstrapApp
	apps: {
		for name, weight in _in.bootstrap {
			"\(name)": {
				machine_type: ctx.machine_type
				machine_name: ctx.machine_name
				app_name:     name
				app_wave:     weight
			}
		}
	}
}

#EnvBootstrapApp: {
	machine_type: string
	machine_name: string
	app_name:     string
	app_wave:     int

	application: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"

		metadata: {
			namespace: "argocd"
			if app_name =~ "^\(machine_type)-\(machine_name)-" {
				name: "\(app_name)"
			}
			if app_name !~ "^\(machine_type)-\(machine_name)-" {
				name: "\(machine_type)-\(machine_name)-\(app_name)"
			}
			annotations: "argocd.argoproj.io/sync-wave": "\(app_wave)"
		}

		spec: {
			project: "default"

			destination: {
				name: "\(machine_type)-\(machine_name)"
			}

			source: {
				repoURL:        "https://github.com/amanibhavam/dotfiles"
				targetRevision: "master"
				path:           "k/\(app_name)"
			}

			syncPolicy: automated: {
				prune:    true
				selfHeal: true
			}

			ignoreDifferences: [{
				group: ""
				kind:  "Secret"
				jsonPointers: ["/data"]
				name:      "karpenter-cert"
				namespace: "karpenter"
			}]
		}
	}
}

// Machine
#Machine: {
	type: string
	name: string

	bootstrap: [string]: int
	env: #EnvApp
	env: {
		// ex: k/k3d-control
		// ex: k/vcluster-vc1
		spec: source: path: "k/\(type)-\(name)"

		spec: destination: name: "in-cluster"
	}
}

#EnvApp: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"

	metadata: {
		namespace: "argocd"
		name:      string
	}

	spec: {
		project: "default"

		destination: name: string
		source: {
			repoURL:        "https://github.com/amanibhavam/dotfiles"
			targetRevision: "master"
			path:           string
		}

		syncPolicy: automated: {
			prune:    bool | *true
			selfHeal: bool | *true
		}
	}
}

#K3DMachineInput: {
	#EnvInput
}

// K3D Machine
#TransformK3DMachine: {
	from: #K3DMachineInput
	to:   #K3DMachine
}

#K3DMachine: ctx={
	_in: #K3DMachineInput

	#Machine

	type:      "k3d"
	name:      _in.name
	bootstrap: _in.bootstrap

	// ex: k3d-control
	env: metadata: name: "\(type)-\(ctx.name)"
}

#VClusterMachineInput: {
	#EnvInput
	instance_types: [...string]
	parent: #K3DMachine
}

// VCluster Machine
#TransformVClusterMachine: {
	from: #VClusterMachineInput
	to:   #VClusterMachine
}

#VClusterMachine: ctx={
	_in: #VClusterMachineInput

	#Machine

	type:           "vcluster"
	name:           _in.name
	bootstrap:      _in.bootstrap
	instance_types: _in.instance_types
	parent:         #K3DMachine & _in.parent

	instance_types: [...string] | *["t3.medium", "t3a.medium"]

	// ex: k3d-control-vc1
	env: metadata: name: "\(type)-\(ctx.name)"
}
