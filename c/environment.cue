package c

import (
	"encoding/yaml"
)

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
}

bootstrap: control: #BootstrapMachine & {
	machine_type: "k3d"

	apps: {
		"cert-manager":     10
		"external-secrets": 10
		"kyverno":          10
		"argo-events":      10
		"knative":          10

		"kong": 100

		"hello": 1000
	}
}

bootstrap: circus: {
	machine_type: "k3d"

	apps: {
		"kyverno": 10
	}
}

bootstrap: smiley: {
	machine_type: "k3d"

	apps: {
		"kyverno": 10
	}
}

for _machine_name, _machine in bootstrap {
	kustomize: "\(_machine.machine_type)-\(_machine.machine_name)": #KustomizeHelm & {
		helm: {
			release: "bootstrap"
			name:    "any-resource"
			version: "0.1.0"
			repo:    "https://kiwigrid.github.io"
			values: {
				anyResources: {
					for _app_name, _app in _machine.out {
						"\(_app_name)": yaml.Marshal(_app.out)
					}
				}
			}
		}
	}
}

kustomize: "vc1": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc1"
}

kustomize: "vc2": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc2"
}

kustomize: "vc3": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc3"
}

kustomize: "vc4": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc4"
}
