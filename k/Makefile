SHELL := bash

count ?= 0
ns ?= karpenter

build:
	kustomize build --enable-helm

rebuild:
	rm -rf charts
	$(MAKE) build

karpenter:
	pass hello
	./doit

count:
	 @n $(ns) get pod -o json | jq -r '.items[] | "\(.spec.nodeName) \(.status.phase)"' | sort | uniq -c
