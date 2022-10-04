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
