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
	rm -f tls.crt tls.key ca.crt

	kumactl generate tls-certificate \
	--type=server \
	--hostname=kuma-control-plane.kuma \
	--hostname=kuma-control-plane.kuma.svc \
	--cert-file=tls.crt --key-file=tls.key

	cp tls.crt ca.crt

kuma-zone-cert-apply:
	-pod delete secret kds-ca-certs -n kuma

	pod create secret generic kds-ca-certs -n kuma \
	--from-file=ca.crt=../kuma-global/ca.crt

	-pod delete secret kuma-tls-cert -n kuma 

	pod create secret generic kuma-tls-cert -n kuma \
	--from-file=tls.crt=tls.crt \
	--from-file=tls.key=tls.key \
	--from-file=ca.crt=ca.crt

kuma-global-cert-gen:
	rm -f tls.crt tls.key ca.crt

	kumactl generate tls-certificate \
	--type=server \
	--hostname=kuma-control-plane.kuma \
	--hostname=kuma-control-plane.kuma.svc \
	--hostname=100.64.110.16 \
	--cert-file=tls.crt \
	--key-file=tls.key

	cp tls.crt ca.crt
kuma-global-cert-apply:

	-global delete secret generic-tls-certs -n kuma

	global create secret generic generic-tls-certs -n kuma \
	--from-file=tls.crt=tls.crt \
	--from-file=tls.key=tls.key \
	--from-file=ca.crt=ca.crt

	-global delete secret kds-server-tls -n kuma 

	global create secret tls kds-server-tls -n kuma \
	--cert=tls.crt \
	--key=tls.key
