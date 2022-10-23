package c

// Match the kuma namespce
match_kuma_ns: match: any: [{
	resources: {
		kinds: [
			"Namespace",
		]
		names: [
			"kuma",
		]
	}
}]

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"argo-cd":                   1
		"kyverno":                   10
		"external-secrets-operator": 10
		"cert-manager":              10
		"argo-events":               10
		"k3d-control-secrets-store": 20
		"k3d-control-kuma-zone":     30
		"knative":                   50
		"kong":                      60
		"demo1":                     100
		"events":                    100
		"blocker":                   101
		"hello":                     110
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	bootstrap: {
		"kyverno":                   10
		"external-secrets-operator": 10
		"k3d-smiley-secrets-store":  20
		"k3d-smiley-kuma-zone":      30
		"demo2":                     100
	}
}

// Env: global is the global control plane, used by all machines.
env: global: #K3D & {
	bootstrap: {
		"kyverno":                   10
		"external-secrets-operator": 10
		"k3d-global-secrets-store":  20
		"k3d-global-kuma-global":    30
		"mesh":                      40
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
