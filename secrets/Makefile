SHELL := bash

count ?= 0
ns ?= karpenter

build:
	mkdir -p out
	kustomize build --enable-helm > out/main.yaml

rebuild:
	rm -rf charts out
	$(MAKE) build

test:
	kustomize build out > out/same.yaml
	diff out/main.yaml out/same.yaml

karpenter:
	pass hello
	./doit

count:
	 @n $(ns) get pod -o json | jq -r '.items[] | "\(.spec.nodeName) \(.status.phase)"' | sort | uniq -c

kuma-zone-cert-gen:
	rm -f kuma-zone-tls.crt kuma-zone-tls.key kuma-zone-ca.crt

	kumactl generate tls-certificate \
		--type=server \
		--hostname=kuma-control-plane.kuma \
		--hostname=kuma-control-plane.kuma.svc \
		--cert-file=kuma-zone-tls.crt \
		--key-file=kuma-zone-tls.key

	cp kuma-zone-tls.crt kuma-zone-ca.crt

kuma-global-cert-gen:
	rm -f kuma-global-tls.crt kuma-global-tls.key kuma-global-ca.crt

	kumactl generate tls-certificate \
		--type=server \
		--hostname=kuma-control-plane.kuma \
		--hostname=kuma-control-plane.kuma.svc \
		--hostname=100.64.110.16 \
		--cert-file=kuma-global-tls.crt \
		--key-file=kuma-global-tls.key

	cp kuma-global-tls.crt kuma-global-ca.crt

secrets:
	-pod create ns secrets
	-circus create ns secrets

	-pod delete secret kuma-zone-kds-ca-certs -n secrets

	pod create secret generic kuma-zone-kds-ca-certs -n secrets \
		--from-file=ca.crt=kuma-global-ca.crt

	-pod delete secret kuma-zone-kuma-tls-cert -n secrets

	pod create secret generic kuma-zone-kuma-tls-cert -n secrets \
		--from-file=tls.crt=kuma-global-tls.crt \
		--from-file=tls.key=kuma-global-tls.key \
		--from-file=ca.crt=kuma-global-ca.crt

	-circus delete secret kuma-global-generic-tls-certs -n secrets

	circus create secret generic kuma-global-generic-tls-certs -n secrets \
		--from-file=tls.crt=kuma-global-tls.crt \
		--from-file=tls.key=kuma-global-tls.key \
		--from-file=ca.crt=kuma-global-ca.crt

	-circus delete secret kuma-global-kds-server-tls -n secrets

	circus create secret tls kuma-global-kds-server-tls -n secrets \
		--cert=kuma-global-tls.crt \
		--key=kuma-global-tls.key
