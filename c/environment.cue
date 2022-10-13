package c

import (
	core "github.com/defn/boot/k8s.io/api/core/v1"
)

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"k3d-control-secrets": 1

		"cert-manager":     10
		"external-secrets": 10
		"kyverno":          10
		"argo-events":      10
		"knative":          10

		"kong": 100

		"hello": 1000
	}
}

kustomize: "k3d-control-secrets": #Kustomize & {
	namespace: "secrets"

	resource: "namespace-secrets": core.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: "secrets"
		}
	}

	_secrets: [
		"kuma-zone-kds-ca-certs",
		"kuma-zone-kuma-tls-cert",
	]

	resource: "pod-secrets": core.#Pod & {
		apiVersion: "v1"
		kind:       "Pod"
		metadata: name: "secrets"
		spec: {
			containers: [{
				name:  "sleep"
				image: "ubuntu"
				command: ["bash", "-c"]
				args: ["sleep", "infinity"]

				volumeMounts: [
					for s in _secrets {
						name:      s
						mountPath: "/mnt/secrets/\(s)"
						readOnly:  true
					},
				]
			}]
			volumes: [
				for s in _secrets {
					name: s
					secret: {
						secretName: s
						optional:   false
					}
				},
			]
		}
	}
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
	bootstrap: {
		"kyverno": 10
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	bootstrap: {
		"kyverno": 10
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
