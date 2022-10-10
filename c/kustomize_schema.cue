package c

kustomize: [string]: #KustomizeHelm | #KustomizeVCluster | #Kustomize

#Helm: {
	release: string
	name:    string
	version: string
	repo:    string

	values: {...} | *{}
}

#Resource: {
	kind: string | *""

	...
}

#Kustomize: {
	namespace: string
	let kns = namespace

	psm: {...} | *{}

	resource: {...} | *{}
	resource: [string]: #Resource

	out: {
		namespace: kns

		patchesStrategicMerge: [
			for _psm_name, _psm in psm {
				"\(_psm_name).yaml"
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
			namespace:   ctx.namespace
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
}
