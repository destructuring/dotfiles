package env

#Env: {
	_type: string
	_name: string

	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"

	metadata: {
		namespace: "argocd"
	}

	spec: {
		project: "default"

		destination: name: "in-cluster"
		source: {
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"
		}
	}
}

#K3D: ctx={
	#Env

	_type: "k3d"

	metadata: {
		name: "k3d-\(ctx._name)"
	}

	spec: {
		source: {
			path: "e/k3d-\(ctx._name)"
		}

		syncPolicy: {
			automated: {
				prune: true
			}
		}
	}
}

#VCluster: ctx={
	#Env

	_type: "vcluster"

	metadata: {
		name: "\(ctx._name)"
		...
	}

	spec: {
		source: {
			path: "e/\(ctx._name)"
			...
		}
		...
	}

	...
}

env: [NAME=string]: (#K3D | #VCluster) & {_name: NAME}

env: circus: #K3D & {
}

env: control: #K3D & {
}

env: smiley: #K3D & {
}

env: vc2: #VCluster & {
}

env: vc3: #VCluster & {
}

env: vc4: #VCluster & {
}
