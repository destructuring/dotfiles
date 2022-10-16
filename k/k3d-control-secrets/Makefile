SHELL := bash

context ?= pod

secrets:
	$(context) create ns secrets 2>/dev/null || true

	$(context) delete secret kuma-zone-kds-ca-certs -n secrets 2>/dev/null || true

	$(context) create secret generic kuma-zone-kds-ca-certs -n secrets \
		--from-file=ca.crt=../k3d-circus-secrets/kuma-global-ca.crt

	$(context) delete secret kuma-zone-kuma-tls-cert -n secrets 2>/dev/null || true

	$(context) create secret generic kuma-zone-kuma-tls-cert -n secrets \
		--from-file=tls.crt=kuma-zone-tls.crt \
		--from-file=tls.key=kuma-zone-tls.key \
		--from-file=ca.crt=kuma-zone-ca.crt

gen:
	rm -f kuma-zone-tls.crt kuma-zone-tls.key kuma-zone-ca.crt

	kumactl generate tls-certificate \
		--type=server \
		--hostname=kuma-control-plane.kuma \
		--hostname=kuma-control-plane.kuma.svc \
		--cert-file=kuma-zone-tls.crt \
		--key-file=kuma-zone-tls.key

	chmod 600 kuma-zone-tls.key

	cp kuma-zone-tls.crt kuma-zone-ca.crt
