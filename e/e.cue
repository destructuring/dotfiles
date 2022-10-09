package env

#EnvApp: {
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
	type: "k3d"
	name: string

	env: {
		#EnvApp

		metadata: {
			name: "k3d-\(ctx.name)"
		}

		spec: {
			source: path: "e/k3d-\(ctx.name)"

			syncPolicy: automated: prune: true
		}
	}
}

#VCluster: ctx={
	type: "vcluster"
	name: string

	k3d: #K3D

	env: {
		#EnvApp

		metadata: {
			name: "\(k3d.env.metadata.name)-\(ctx.name)"
		}
		spec: {
			source: path: "e/\(ctx.name)"
		}
	}

	vcluster: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"
		metadata: {
			name:      "\(ctx.env.metadata.name)-vcluster"
			namespace: "argocd"
		}
		spec: {
			project: "default"
			source: {
				repoURL:        "https://github.com/defn/app"
				path:           "k/\(ctx.env.metadata.name)"
				targetRevision: "master"
			}
			destination: {
				namespace: ctx.env.metadata.name
				name:      "in-cluster"
			}
			syncPolicy: syncOptions: ["CreateNamespace=true"]
		}
	}

	appset: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "ApplicationSet"
		metadata: {
			name:      ctx.env.metadata.name
			namespace: "argocd"
		}
		spec: {
			generators: [{
				list: elements: [{
					name:      "dev"
					namespace: "default"
					path:      "dev"
					cluster:   ctx.env.metadata.name
				}]
			}]
			template: {
				metadata: {
					name:      "\(ctx.env.metadata.name)-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: {
						namespace: "{{namespace}}"
						name:      "{{cluster}}"
					}
					syncPolicy: syncOptions: ["CreateNamespace=true"]
				}
			}
		}
	}
}

env: [NAME=string]: name: NAME
env: [NAME=string]: #K3D | #VCluster

env: circus: #K3D & {
}

env: control: #K3D & {
}

env: smiley: #K3D & {
}

env: vc1: #VCluster & {
	k3d: env.control
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
