SHELL := /bin/bash

check:
	cue fmt
	cue eval -c

gen:
	$(MAKE) check
	find ../e/ -name '*.yaml' | xargs rm -fv
	rm -fv ../k/*/kustomization.yaml
	rm -fv ../k/*/resource-*.yaml
	rm -fv ../k/*/patch-*.yaml
	c gen
