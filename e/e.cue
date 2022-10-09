package env

#K3D: {
	_type: "k3d"
	...
}

#VCluster: {
	_type: "vcluster"
	...
}

env: [NAME=string]: ctx={
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		namespace: "argocd"

		if ctx._type == "k3d" {
			name: "k3d-\(NAME)"
		}

		if ctx._type == "vcluster" {
			name: "\(NAME)"
		}
	}

	spec: {
		project: "default"

		destination: name: "in-cluster"
		source: {
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"

			if ctx._type == "k3d" {
				path: "e/k3d-\(NAME)"
			}

			if ctx._type == "vcluster" {
				path: "e/\(NAME)"
			}
		}

		if ctx._type == "k3d" {
			syncPolicy: automated: prune: true
		}
	}
}

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
