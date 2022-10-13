SHELL := bash

secrets:
	circus create ns secrets 2>/dev/null || true

	circus delete secret kuma-global-generic-tls-cert -n secrets 2>/dev/null || true

	circus create secret generic kuma-global-generic-tls-cert -n secrets \
		--from-file=tls.crt=kuma-global-tls.crt \
		--from-file=tls.key=kuma-global-tls.key \
		--from-file=ca.crt=kuma-global-ca.crt

	circus delete secret kuma-global-kds-server-tls -n secrets 2>/dev/null || true

	circus create secret tls kuma-global-kds-server-tls -n secrets \
		--cert=kuma-global-tls.crt \
		--key=kuma-global-tls.key

gen:
	rm -f kuma-global-tls.crt kuma-global-tls.key kuma-global-ca.crt

	kumactl generate tls-certificate \
		--type=server \
		--hostname=kuma-control-plane.kuma \
		--hostname=kuma-control-plane.kuma.svc \
		--hostname=100.64.110.16 \
		--cert-file=kuma-global-tls.crt \
		--key-file=kuma-global-tls.key

	cp kuma-global-tls.crt kuma-global-ca.crt
