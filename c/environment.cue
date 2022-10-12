package c

import (
	"encoding/yaml"
)

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
}

// Env: VClusters

env: {
	// VClusters on control machine
	_vc_machine: #VCluster & {machine: env.control}

	// The VClusters
	//vc1: _vc_machine & _vc_apps
	//vc2: _vc_machine & _vc_apps
	//vc3: _vc_machine & _vc_apps
	//vc4: _vc_machine & _vc_apps
}
bootstrap: control: {
	for a, w in {"cert-manager": 10, "external-secrets": 10, kyverno: 10, "argo-events": 10, knative: 10, kong: 100, hello: 1000} {
		"\(a)": {
			apiVersion: "argoproj.io/v1alpha1"
			kind:       "Application"

			metadata: {
				namespace: "argocd"
				name:      "k3d-control-\(a)"
				annotations: "argocd.argoproj.io/sync-wave": "\(w)"
			}

			spec: {
				project: "default"

				destination: name: "in-cluster"
				source: {
					repoURL:        "https://github.com/defn/app"
					targetRevision: "master"
					path:           "k/\(a)"
				}

				syncPolicy: automated: prune: true
			}
		}
	}
}

bootstrap: circus: {
	for a, w in {kyverno: 10} {
		"\(a)": {
			apiVersion: "argoproj.io/v1alpha1"
			kind:       "Application"

			metadata: {
				namespace: "argocd"
				name:      "k3d-circus-\(a)"
				annotations: "argocd.argoproj.io/sync-wave": "\(w)"
			}

			spec: {
				project: "default"

				destination: name: "in-cluster"
				source: {
					repoURL:        "https://github.com/defn/app"
					targetRevision: "master"
					path:           "k/\(a)"
				}

				syncPolicy: automated: prune: true
			}
		}
	}
}

bootstrap: smiley: {
	for a, w in {kyverno: 10} {
		"\(a)": {
			apiVersion: "argoproj.io/v1alpha1"
			kind:       "Application"

			metadata: {
				namespace: "argocd"
				name:      "k3d-smiley-\(a)"
				annotations: "argocd.argoproj.io/sync-wave": "\(w)"
			}

			spec: {
				project: "default"

				destination: name: "in-cluster"
				source: {
					repoURL:        "https://github.com/defn/app"
					targetRevision: "master"
					path:           "k/\(a)"
				}

				syncPolicy: automated: prune: true
			}
		}
	}
}

kustomize: "k3d-control": #KustomizeHelm & {
	helm: {
		release: "bootstrap"
		name:    "any-resource"
		version: "0.1.0"
		repo:    "https://kiwigrid.github.io"
		values: {
			anyResources: {
				for a, h in bootstrap.control {
					"\(a)": yaml.Marshal(h)
				}
			}
		}
	}
}

kustomize: "k3d-circus": #KustomizeHelm & {
	helm: {
		release: "bootstrap"
		name:    "any-resource"
		version: "0.1.0"
		repo:    "https://kiwigrid.github.io"
		values: {
			anyResources: {
				for a, h in bootstrap.circus {
					"\(a)": yaml.Marshal(h)
				}
			}
		}
	}
}

kustomize: "k3d-smiley": #KustomizeHelm & {
	helm: {
		release: "bootstrap"
		name:    "any-resource"
		version: "0.1.0"
		repo:    "https://kiwigrid.github.io"
		values: {
			anyResources: {
				for a, h in bootstrap.smiley {
					"\(a)": yaml.Marshal(h)
				}
			}
		}
	}
}

kustomize: "vc1": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc1"
}

kustomize: "vc2": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc2"
}

kustomize: "vc3": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc3"
}

kustomize: "vc4": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc4"
}
