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
		"cert-manager":              1
		"pod-identity-webhook":      10
		"kyverno":                   10
		"external-secrets-operator": 10
		"argo-events":               10
		"karpenter":                 20
		"k3d-control-secrets-store": 20
		//"k3d-control-kuma-zone":     30
		//"vc1": 30
		//"vc2": 30
		//"vc3": 30
		//"vc4": 30
		//"knative":                   50
		//"kong":                      60
		//"demo1":                     100
		"events": 100
		//"hello":                     110
		"tfo":     200
		"argo-cd": 300
		"chicken": 400
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	bootstrap: {
		"cert-manager":              1
		"pod-identity-webhook":      10
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
		"cert-manager":              1
		"pod-identity-webhook":      10
		"kyverno":                   10
		"external-secrets-operator": 10
		"k3d-global-secrets-store":  20
		"k3d-global-kuma-global":    30
		"mesh":                      40
	}
}

kustomize: [NAME=string]: {
	if NAME =~ "^vc" {
		#KustomizeVCluster & {
			namespace:  NAME
			vc_name:    NAME
			vc_machine: NAME
		}
	}
}

kustomize: "vc1": {}
kustomize: "vc2": {}
kustomize: "vc3": {}
kustomize: "vc4": {}
