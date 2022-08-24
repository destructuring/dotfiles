SHELL := bash

build:
	kustomize build --enable-helm

rebuild:
	rm -rf charts
	$(MAKE) build

