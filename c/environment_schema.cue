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
		// ex: k/vcluster-vc1-bootstrap
		spec: source: path: "k/\(type)-\(name)"

		spec: syncPolicy: automated: prune: true
	}

	apps: [string]: [string]: {...}
}

// K3D Machine
#K3D: ctx={
	#Machine
	type: "k3d"

	// ex: k3d-control
	env: metadata: name: "\(type)-\(ctx.name)"

	env: spec: destination: {
		if ctx.name == "control" {
			name: "in-cluster"
		}
		if ctx.name != "control" {
			name: "\(type)-\(ctx.name)"
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

	env: spec: destination: {
		if machine.env.metadata.name == "k3d-control" {
			name: "in-cluster"
		}
		if machine.env.metadata.name != "k3d-control" {
			name: "\(type)-\(ctx.name)"
		}
	}

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

			destination: {
				name: string
				if machine_name == "control" {
					name: "in-cluster"
				}
				if machine_name != "control" {
					name: "\(machine_type)-\(machine_name)"
				}
			}

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
