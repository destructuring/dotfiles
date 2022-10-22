package c

import (
	"encoding/yaml"

	core "github.com/defn/boot/k8s.io/api/core/v1"
)

// Each environment is hosted on a Kubernetes machine.
// The machine's name is set to the env key.
env: [NAME=string]: (#K3D | #VCluster) & {
	name: NAME
}

bootstrap: [NAME=string]: #BootstrapMachine & {
	machine_name: NAME
}

// Each environment is deployed as a Kustomize bundle: any-resource helm chart
// with all the bootstrap applications.
for _machine_name, _machine in env {
	// Create a bootstrap machine
	bootstrap: "\(_machine_name)": {
		machine_type: _machine.type
		apps:         _machine.bootstrap
	}

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
	kustomize: "\(_machine.type)-\(_machine.name)-secrets": #Kustomize & {
		namespace: "secrets"

		resource: "namespace-secrets": core.#Namespace & {
			apiVersion: "v1"
			kind:       "Namespace"
			metadata: {
				name: "secrets"
			}
		}

		resource: "kyverno-sync-secrets": {
			apiVersion: "kyverno.io/v1"
			kind:       "ClusterPolicy"
			metadata: name: "kyverno-sync-secrets"

			spec: rules: [...{...}]
			spec: rules: [
				for sname, s in _machine.sync {
					s & {name: sname}
				},
			]
		}

		resource: {
			for ename, e in _machine.external {
				"\(ename)": e.out
			}
		}

		resource: "pod-secrets": core.#Pod & {
			apiVersion: "v1"
			kind:       "Pod"
			metadata: name: "secrets"

			spec: {
				containers: [{
					name:  "sleep"
					image: "ubuntu"
					command: ["bash", "-c"]
					args: ["sleep infinity"]

					volumeMounts: [
						for sname, s in _machine.sync {
							name:      sname
							mountPath: "/mnt/secrets/\(sname)"
							readOnly:  true
						},
					]
				}]

				volumes: [
					for sname, s in _machine.sync {
						name: sname
						secret: {
							secretName: sname
							optional:   false
						}
					},
				]
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
		// ex: k/vcluster-vc1
		spec: source: path: "k/\(type)-\(name)"

		spec: destination: name: "in-cluster"
	}

	apps: [string]: [string]: {...}

	sync: [string]: {...}

	external: [string]: #VaultSecret
}

// K3D Machine
#K3D: ctx={
	#Machine
	type: "k3d"

	// ex: k3d-control
	env: metadata: name: "\(type)-\(ctx.name)"
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
