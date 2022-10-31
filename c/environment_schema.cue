package c

import (
	"encoding/yaml"
)

// Each environment is hosted on a Kubernetes machine.
// The machine's name is set to the env key.
env: [NAME=string]: (#K3D | #VCluster) & {
	name: NAME
}

bootstrap: (#Transform & {
	transformer: #TransformEnvToBootstrapMachine

	inputs: {
		for _env_name, _env in env {
			"\(_env_name)": {
				name:      _env_name
				type:      _env.type
				bootstrap: _env.bootstrap
			}
		}
	}
}).outputs

#TransformEnvToBootstrapMachine: {
	from: {
		#Input

		type: string
		bootstrap: [string]: int
	}

	to: #BootstrapMachine
}

#BootstrapMachine: ctx={
	_in: #TransformEnvToBootstrapMachine.from

	machine_name: string | *_in.name
	machine_type: string | *_in.type

	apps: [string]: int
	apps: {...} | *_in.bootstrap

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

// Each environment is deployed as a Kustomize bundle: any-resource helm chart
// with all the bootstrap applications.
for _machine_name, _machine in env {
	// Deploy the bootstrap machine application
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

	// Configure the environment secrets
	kustomize: "\(_machine.type)-\(_machine.name)-secrets-store": #Kustomize & {
		_vault_mount_path: "\(_machine.type)-\(_machine.name)"

		resource: "cluster-secret-store-dev": {
			apiVersion: "external-secrets.io/v1beta1"
			kind:       "ClusterSecretStore"
			metadata: name: "dev"
			spec: provider: vault: {
				server:  "http://100.103.25.109:8200"
				path:    "kv"
				version: "v2"
				auth: kubernetes: {
					mountPath: _vault_mount_path
					role:      "external-secrets"
				}
			}
		}
	}
}

// Env Application to deploy ApplicationSets, VCluster Applications
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
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"
			path:           string
		}

		syncPolicy: automated: {
			prune:    bool | *true
			selfHeal: bool | *true
		}
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
			name:      string
		}
		syncPolicy: syncOptions: ["CreateNamespace=true"]
	}
}

// Machines run ApplicationSets
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

	apps: [string]: [string]: {...}
}

// K3D Machine
#TransformK3D: {
	from: {
		#Input
		bootstrap: [string]: number
	}

	to: #K3D
}

#K3D: ctx={
	_in: #TransformK3D.from

	#Machine

	type:      "k3d"
	bootstrap: _in.bootstrap

	// ex: k3d-control
	env: metadata: name: "\(type)-\(ctx.name)"
}

// VCluster Machine
#TransformVCluster: {
	from: {
		#Input
		bootstrap: [string]: number
	}

	to: from
}

#VCluster: ctx={
	_in: #TransformVCluster.from

	#Machine

	type:      "vcluster"
	bootstrap: _in.bootstrap

	machine: #K3D

	// ex: k3d-control-vc1
	env: metadata: name: "\(machine.env.metadata.name)-\(ctx.name)"

	vcluster: #VClusterApp & {
		// ex: vc1-vcluster
		metadata: name: "\(ctx.name)-vcluster"

		// ex: k/vcluster-vc1
		spec: source: path: "k/\(type)-\(ctx.name)"
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
				repoURL:        "https://github.com/defn/app"
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
