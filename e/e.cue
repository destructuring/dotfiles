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

// VClusters on control run dev environments
env: {
	_vc: #VCluster & {machine: env.control}

	_vc_apps: apps: default: {
		"dev": {
			namespace: "default"
		}
	}

	vc1: _vc & _vc_apps
	vc2: _vc & _vc_apps
	vc3: _vc & _vc_apps
	vc4: _vc & _vc_apps
}
