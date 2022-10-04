SHELL := bash

count ?= 0
ns ?= karpenter

build:
	mkdir -p out
	kustomize build --enable-helm > out/main.yaml

rebuild:
	rm -rf charts out
	$(MAKE) build

karpenter:
	pass hello
	./doit

count:
	 @n $(ns) get pod -o json | jq -r '.items[] | "\(.spec.nodeName) \(.status.phase)"' | sort | uniq -c

kuma-zone-cert-gen:
	kumactl generate tls-certificate \
	--type=server \
	--hostname=kuma-control-plane.kuma \
	--hostname=kuma-control-plane.kuma.svc \
	--cert-file=tls.crt --key-file=tls.key

	cp tls.crt ca.crt

kuma-zone-cert-apply:
	$(context) create secret generic kuma-tls-cert -n kuma \
	--from-file=tls.crt=tls.crt \
	--from-file=tls.key=tls.key \
	--from-file=ca.crt=ca.crt
