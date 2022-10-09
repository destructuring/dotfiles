package env

#Env: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"

	metadata: {
		namespace: "argocd"
		...
	}

	spec: {
		project: "default"

		destination: name: "in-cluster"
		source: {
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"
			...
		}
		...
	}

	...
}

#K3D: #Env & {
	_type: "k3d"
	_name: string

	metadata: {
		name: "k3d-\(_name)"
		...
	}

	spec: {
		source: {
			path: "e/k3d-\(_name)"
			...
		}

		syncPolicy: {
			automated: {
				prune: true
				...
			}
			...
		}
		...
	}

	...
}

#VCluster: #Env & {
	_type: "vcluster"
	_name: string

	metadata: {
		name: "\(_name)"
		...
	}

	spec: {
		source: {
			path: "e/\(_name)"
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
