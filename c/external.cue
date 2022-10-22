package c

#VaultSecret: {
	secret_name:      string
	secret_namespace: string
	secret_key:       string
	secret_template:  {...} | *null
	secret_refresh:   string
	secret_store:     string

	out: {
		apiVersion: "external-secrets.io/v1beta1"
		kind:       "ExternalSecret"
		metadata: {
			name:      secret_name
			namespace: secret_namespace
		}
		spec: {
			target: {
				name: secret_name
				if secret_template != null {
					template: data: secret_template
				}
			}

			dataFrom: [{
				extract: key: secret_key
			}]

			refreshInterval: secret_refresh
			secretStoreRef: {
				name: secret_store
				kind: "ClusterSecretStore"
			}
		}
	}
}
