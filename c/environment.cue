package c

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"argo-cd":             1
		"cert-manager":        10
		"external-secrets":    10
		"argo-events":         10
		"kyverno":             10
		"k3d-control-secrets": 20
		"kuma-zone":           30
		"knative":             50
		"kong":                60
		"hello":               100
		"demo":                100
	}

	sync: "kuma-zone-kds-ca-certs": {
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
	}

	sync: "kuma-zone-kuma-tls-cert": {
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
	}
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
	bootstrap: {
		"kyverno":            10
		"k3d-circus-secrets": 20
		"kuma-global":        30
		"mesh":               40
	}

	sync: "kuma-global-kds-server-tls": {
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
	}

	sync: "kuma-global-generic-tls-cert": {
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
