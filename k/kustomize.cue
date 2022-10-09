package kustomize

kustomize: "argo-cd": {
	helm: {
		release:   "argocd"
		name:      "argo-cd"
		namespace: "argocd"
		version:   "5.5.11"
		repo:      "https://argoproj.github.io/argo-helm"
	}

	psm: "configmap-argocd-cm": {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name: "argocd-cm"
		data: {
			"kustomize.buildOptions": "--enable-helm"
			"resource.customizations.health.networking.k8s.io_Ingress": """
				hs = {}
				hs.status = \"Healthy\"
				return hs

				"""

			"resource.customizations.ignoreDifferences.admissionregistration.k8s.io_MutatingWebhookConfiguration": """
				jsonPointers:
				  - /webhooks/0/clientConfig/caBundle
				  - /webhooks/0/rules

				"""

			"resource.customizations.ignoreDifferences.admissionregistration.k8s.io_ValidatingWebhookConfiguration": """
				jsonPointers:
				  - /webhooks/0/rules

				"""

			"resource.customizations.ignoreDifferences.apps_Deployment": """
				jsonPointers:
				  - /spec/template/spec/tolerations

				"""

			"resource.customizations.ignoreDifferences.kyverno.io_ClusterPolicy": """
				jqPathExpressions:
				  - .spec.rules[] | select(.name|test(\"autogen-.\"))

				"""
		}
	}
}

kustomize: "argo-events": {
	helm: {
		release:   "argo-events"
		name:      "argo-events"
		namespace: "argo-events"
		version:   "2.0.6"
		repo:      "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "argo-workflows": {
	helm: {
		release:   "argo-workflows"
		name:      "argo-workflows"
		namespace: "argo-workflows"
		version:   "0.20.1"
		repo:      "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "kyverno": {

	helm: {
		release:   "kyverno"
		name:      "kyverno"
		namespace: "kyverno"
		version:   "2.5.2"
		repo:      "https://kyverno.github.io/kyverno"
		values: {
			replicaCount: 1
		}
	}
}

kustomize: "vc1": #KustomizeVCluster & {
	vc_name: "vc1"
}

kustomize: "vc2": #KustomizeVCluster & {
	vc_name: "vc2"
}

kustomize: "vc3": #KustomizeVCluster & {
	vc_name: "vc3"
}

kustomize: "vc4": #KustomizeVCluster & {
	vc_name: "vc4"
}
