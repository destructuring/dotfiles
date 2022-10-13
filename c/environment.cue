package c

import (
	core "github.com/defn/boot/k8s.io/api/core/v1"
)

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"cert-manager":        10
		"external-secrets":    10
		"argo-events":         10
		"knative":             10
		"kyverno":             10
		"k3d-control-secrets": 20
		"kuma-zone":           30
		"kong":                40
		"hello":               100
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

	resource: "kyverno-sync-secrets": {
		apiVersion: "kyverno.io/v1"
		kind:       "ClusterPolicy"
		metadata: name: "sync-secret-kuma-zone"
		spec: rules: [{
			name: "sync-secret-kuma-zone-kuma-tls-cert"
			match: any: [{
				resources: {
					kinds: [
						"Namespace",
					]
					names: [
						"kuma",
					]
				}
			}]
			generate: {
				apiVersion:  "v1"
				kind:        "Secret"
				name:        "kuma-tls-cert"
				namespace:   "{{request.object.metadata.name}}"
				synchronize: true
				clone: {
					namespace: "secrets"
					name:      "kuma-zone-kuma-tls-cert"
				}
			}
		}, {
			name: "sync-secret-kuma-zone-kds-ca-certs"
			match: any: [{
				resources: {
					kinds: [
						"Namespace",
					]
					names: [
						"kuma",
					]
				}
			}]
			generate: {
				apiVersion:  "v1"
				kind:        "Secret"
				name:        "kds-ca-certs"
				namespace:   "{{request.object.metadata.name}}"
				synchronize: true
				clone: {
					namespace: "secrets"
					name:      "kuma-zone-kds-ca-certs"
				}
			}
		}]
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
		"kyverno":            10
		"k3d-circus-secrets": 20
		"kuma-global":        30
	}
}

kustomize: "k3d-circus-secrets": #Kustomize & {
	namespace: "secrets"

	resource: "namespace-secrets": core.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: "secrets"
		}
	}

	_secrets: [
		"kuma-global-kds-server-tls",
		"kuma-global-generic-tls-cert",
	]

	resource: "kyverno-sync-secrets": {
		apiVersion: "kyverno.io/v1"
		kind:       "ClusterPolicy"
		metadata: name: "sync-secret-kuma-global"
		spec: rules: [{
			name: "sync-secret-kuma-global-generic-tls-cert"
			match: any: [{
				resources: {
					kinds: [
						"Namespace",
					]
					names: [
						"kuma",
					]
				}
			}]
			generate: {
				apiVersion:  "v1"
				kind:        "Secret"
				name:        "generic-tls-cert"
				namespace:   "{{request.object.metadata.name}}"
				synchronize: true
				clone: {
					namespace: "secrets"
					name:      "kuma-global-generic-tls-cert"
				}
			}
		}, {
			name: "sync-secret-kuma-zone-kds-server-tls"
			match: any: [{
				resources: {
					kinds: [
						"Namespace",
					]
					names: [
						"kuma",
					]
				}
			}]
			generate: {
				apiVersion:  "v1"
				kind:        "Secret"
				name:        "kds-server-tls"
				namespace:   "{{request.object.metadata.name}}"
				synchronize: true
				clone: {
					namespace: "secrets"
					name:      "kuma-global-kds-server-tls"
				}
			}
		}]
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
