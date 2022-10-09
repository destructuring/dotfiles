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

// Env: vc1..vc4 is one of many vcluster machines.  The k3d machine must be set.
env: vc1: #VCluster & {
	machine: env.control

	apps: default: {
		"dev": {
			namespace: "default"
		}
	}
}

env: vc2: #VCluster & {
	machine: env.control
}

env: vc3: #VCluster & {
	machine: env.control
}

env: vc4: #VCluster & {
	machine: env.control
}
