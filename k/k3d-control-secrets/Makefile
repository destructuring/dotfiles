SHELL := bash

secrets:
	pod create ns secrets 2>/dev/null || true
	
	pod delete secret kuma-zone-kds-ca-certs -n secrets 2>/dev/null || true

	pod create secret generic kuma-zone-kds-ca-certs -n secrets \
		--from-file=ca.crt=kuma-global-ca.crt

	pod delete secret kuma-zone-kuma-tls-cert -n secrets 2>/dev/null || true

	pod create secret generic kuma-zone-kuma-tls-cert -n secrets \
		--from-file=tls.crt=kuma-zone-tls.crt \
		--from-file=tls.key=kuma-zone-tls.key \
		--from-file=ca.crt=kuma-zone-ca.crt