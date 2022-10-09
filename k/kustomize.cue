package kustomize

#Kustomize: {
	helm: {...} | *null
	helm: {
		values: {...} | *null
		...
	}

	psm: {...} | {}

	out: {
		namespace: string | *helm.namespace

		if helm != null {
			helmCharts: [{
				releaseName: helm.release
				name:        helm.name
				namespace:   helm.namespace
				version:     helm.version
				repo:        helm.repo
				includeCRDs: true

				if helm.values != null {
					valuesInline: helm.values
				}
			}]
		}

		patchesStrategicMerge: [
			for _psm_name, _psm in psm {
				"\(_psm_name).yaml"
			},
		]
	}

	...
}

kustomize: [string]: #Kustomize

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

#KustomizeVCluster: {
	vc_name:    string
	vc_machine: string | *"control"

	helm: {
		namespace: vc_name

		release: "vcluster"
		name:    "vcluster"
		version: "0.12.2"
		repo:    "https://charts.loft.sh"

		values: {
			service: type:   "ClusterIP"
			vcluster: image: "rancher/k3s:v1.23.12-k3s1"

			syncer: extraArgs: [
				"--tls-san=vcluster.\(vc_name).svc.cluster.local",
				"--enforce-toleration=env=\(vc_name):NoSchedule",
			]

			sync: nodes: {
				enabled:      true
				nodeSelector: "env=\(vc_machine)"
			}

			tolerations: [{
				key:      "env"
				value:    vc_machine
				operator: "Equal"
			}]

			affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
				matchExpressions: [{
					key:      "env"
					operator: "In"
					values: [vc_machine]
				}]
			}]
		}
	}

	...
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
