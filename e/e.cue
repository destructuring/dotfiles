package env

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	appset: default: _apps: [{
		name: "kyverno"
	}, {
		name: "cert-manager"
	}, {
		name: "external-secrets"
	}, {
		name: "argo-cd"
	}, {
		name: "argo-events"
	}, {
		name: "argo-workflows"
	}, {
		name: "knative"
	}]

	appset: nons: _apps: [{
		name: "kourier"
	}]
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
	appset: default: _apps: [{
		name: "kyverno"
	}, {
		name: "cert-manager"
	}, {
		name:      "kuma-global"
		namespace: "kuma"
	}]
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	appset: default: _apps: [{
		name: "kyverno"
	}, {
		name: "cert-manager"
	}]
}

// Env: vc1..vc4 is one of many vcluster machines.  The k3d machine must be set.
env: vc1: #VCluster & {
	k3d: env.control

	appset: default: _apps: [{
		name:      "dev"
		namespace: "default"
	}]
}

env: vc2: #VCluster & {
	k3d: env.control
}

env: vc3: #VCluster & {
	k3d: env.control
}

env: vc4: #VCluster & {
	k3d: env.control
}
