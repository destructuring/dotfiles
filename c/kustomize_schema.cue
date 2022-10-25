package c

import (
	core "github.com/defn/boot/k8s.io/api/core/v1"
)

kustomize: [string]: #KustomizeHelm | #KustomizeVCluster | #Kustomize
kustomize: [NAME=string]: _name: NAME

#Helm: {
	release:   string
	name:      string
	version:   string
	repo:      string
	namespace: string | *""

	values: {...} | *{}
}

#Resource: {
	kind: string | *""

	...
}

#Kustomize: {
	_name: string
	app: "\(_name)": {}

	namespace: string | *""
	let kns = namespace

	psm: {...} | *{}

	resource: {...} | *{}
	resource: [string]: #Resource

	out: {
		if kns != "" {
			namespace: kns
		}

		patchesStrategicMerge: [
			for _psm_name, _psm in psm {
				"patch-\(_psm_name).yaml"
			},
		]

		resources: [
			for _rname, _r in resource {
				if _r.kind == "" {
					_r.url
				}
				if _r.kind != "" {
					"resource-\(_rname).yaml"
				}
			},
		]

		helmCharts?: [...{...}]
	}
}

#KustomizeHelm: ctx={
	#Kustomize

	helm: #Helm

	out: {
		helmCharts: [{
			releaseName: helm.release
			name:        helm.name
			if ctx.namespace != "" {
				namespace: ctx.namespace
			}
			if ctx.namespace == "" {
				if helm.namespace != "" {
					namespace: helm.namespace
				}
			}
			version:     helm.version
			repo:        helm.repo
			includeCRDs: true

			if helm.values != null {
				valuesInline: helm.values
			}
		}]
	}
}

#KustomizeVCluster: {
	#KustomizeHelm

	vc_name:    string
	vc_machine: string

	helm: {
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

	resource: "namespace-vcluster": core.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: vc_name
		}
	}
}
