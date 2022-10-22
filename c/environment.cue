package c

// Match the kuma namespce

match_kuma_ns: match: any: [{
	resources: {
		kinds: [
			"Namespace",
		]
		names: [
			"kuma",
		]
	}
}]

sync_kuma_global_secrets: {
	sync: "kuma-global-kds-server-tls": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "generic-tls-cert"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-global-generic-tls-cert"
			}
		}
	}

	sync: "kuma-global-generic-tls-cert": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "kds-server-tls"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-global-kds-server-tls"
			}
		}
	}

	sync: "kuma-global-kds-server-tls": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "generic-tls-cert"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-global-generic-tls-cert"
			}
		}
	}

	sync: "kuma-global-generic-tls-cert": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "kds-server-tls"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-global-kds-server-tls"
			}
		}
	}
}

sync_kuma_zone_secrets: {
	sync: "kuma-zone-kds-ca-certs": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "kds-ca-certs"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-zone-kds-ca-certs"
			}
		}
	}

	sync: "kuma-zone-kuma-tls-cert": {
		match_kuma_ns

		generate: {
			apiVersion:  "v1"
			kind:        "Secret"
			name:        "kuma-tls-cert"
			namespace:   "{{request.object.metadata.name}}"
			synchronize: true
			clone: {
				namespace: "secrets"
				name:      "kuma-zone-kuma-tls-cert"
			}
		}
	}
}

// Env: control is the control plane, used by the operator.
env: control: #K3D & {
	bootstrap: {
		"argo-cd":               1
		"kyverno":               10
		"external-secrets":      10
		"cert-manager":          10
		"argo-events":           10
		"k3d-control-secrets":   20
		"k3d-control-kuma-zone": 30
		"knative":               50
		"kong":                  60
		"demo1":                 100
		"events":                100
		"blocker":               101
		"hello":                 110

		//"karpenter": 30
	}

	sync_kuma_zone_secrets

	external: "hello": {
		secret_name:      "hello"
		secret_namespace: "default"
		secret_key:       "/dev/meh"
		secret_template: "config.yml": """
			- https://{{ .user }}:{{ .password }}@api.exmaple.com

			"""
		secret_refresh: "15s"
		secret_store:   "dev"
	}
}

// Env: smiley is the second machine used for multi-cluster.
env: smiley: #K3D & {
	bootstrap: {
		"kyverno":              10
		"external-secrets":     10
		"k3d-smiley-secrets":   20
		"k3d-smiley-kuma-zone": 30
		"demo2":                100
		"dev":                  100
	}

	sync_kuma_zone_secrets

	external: "hello": {
		secret_name:      "hello"
		secret_namespace: "default"
		secret_key:       "/dev/meh"
		secret_template: "config.yml": """
			- https://{{ .user }}:{{ .password }}@api.exmaple.com/global

			"""
		secret_refresh: "15s"
		secret_store:   "dev"
	}
}

// Env: global is the global control plane, used by all machines.
env: global: #K3D & {
	bootstrap: {
		"kyverno":                10
		"external-secrets":       10
		"k3d-global-secrets":     20
		"k3d-global-kuma-global": 30
		"mesh":                   40
		"dev":                    100
	}

	sync_kuma_global_secrets

	external: "hello": {
		secret_name:      "hello"
		secret_namespace: "default"
		secret_key:       "/dev/meh"
		secret_template: "config.yml": """
			- https://{{ .user }}:{{ .password }}@api.exmaple.com/global

			"""
		secret_refresh: "15s"
		secret_store:   "dev"
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
