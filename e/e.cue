package env

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	apps: default: {
		"kyverno": {}
		"cert-manager": {}
		"external-secrets": {}
		"argo-cd": {}
		"argo-events": {}
		"argo-workflows": {}
		"knative": {}
	}

	apps: nons: {
		"kourier": {}
	}
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
	apps: default: {
		"kyverno": {}
		"cert-manager": {}
		"kuma-global": {
			namespace: "kuma"
		}
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	apps: default: {
		"kyverno": {}
		"cert-manager": {}
	}
}

env: {
	// VClusters on control machine
	_vc_machine: #VCluster & {machine: env.control}

	// Running dev environments
	_vc_apps: apps: default: {
		"dev": {
			namespace: "default"
		}
	}

	// The VClusters
	vc1: _vc_machine & _vc_apps
	vc2: _vc_machine & _vc_apps
	vc3: _vc_machine & _vc_apps
	vc4: _vc_machine & _vc_apps
}
