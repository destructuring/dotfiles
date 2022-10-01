SHELL := bash

scale ?= 0

build:
	kustomize build --enable-helm

rebuild:
	rm -rf charts
	$(MAKE) build

karpenter:
	pass hello
	./doit

scale:
	pod -n karpenter scale deployment --replicas=$(scale) inflate
