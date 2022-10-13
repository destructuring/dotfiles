package c

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"cert-manager":     10
		"external-secrets": 10
		"kyverno":          10
		"argo-events":      10
		"knative":          10

		"kong": 100

		"hello": 1000
	}
}

// Env: circus is the global control plane, used by all machines.
env: circus: #K3D & {
	bootstrap: {
		"kyverno": 10
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	bootstrap: {
		"kyverno": 10
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
