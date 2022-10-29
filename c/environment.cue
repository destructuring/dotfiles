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
		"argo-cd":                   0
		"cert-manager":              1
		"pod-identity-webhook":      10
		"kyverno":                   10
		"external-secrets-operator": 10
		"argo-events":               10
		"karpenter":                 20
		"k3d-control-secrets-store": 20
		"k3d-control-kuma-zone":     30
		"tfo":                       30
		"knative":                   50
		"kong":                      60
		"egg":                       400
		"chicken":                   401
		//"demo1":  500
		//"events": 500
		//"hello":  500
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
		"tfo":                       30
		"demo2":                     500
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
		"tfo":                       30
		"mesh":                      40
	}
}
