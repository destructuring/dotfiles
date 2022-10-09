package env

env: [NAME=string]: appset: [string]: #AppSet & {
	_name: NAME
}

env: [NAME=string]: #K3D | #VCluster
env: [NAME=string]: name: NAME

env: control: #K3D & {
	appset: default: {
		_apps: [{
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
	}

	appset: nons: {
		_apps: [{
			name: "kourier"
		}]
	}
}

env: circus: #K3D & {
	appset: default: {
		_apps: [{
			name: "kyverno"
		}, {
			name: "cert-manager"
		}, {
			name:      "kuma-global"
			namespace: "kuma"
		}]
	}
}

env: smiley: #K3D & {
	appset: default: {
		_apps: [{
			name: "kyverno"
		}, {
			name: "cert-manager"
		}]
	}
}

env: vc1: #VCluster & {
	k3d: env.control

	appset: default: {
		_apps: [{
			name:      "dev"
			namespace: "default"
		}]
	}
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
