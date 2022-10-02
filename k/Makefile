SHELL := bash

count ?= 0

build:
	kustomize build --enable-helm

rebuild:
	rm -rf charts
	$(MAKE) build

karpenter:
	pass hello
	./doit

scale:
	pod -n karpenter scale deployment --replicas=$(count) inflate
	$(MAKE) count

count:
	 n karpenter get pod -o json | jq -r '.items[].spec.nodeName' | sort | uniq -c
