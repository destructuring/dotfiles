SHELL := /bin/bash

check:
	cue fmt
	cue eval -c

gen:
	$(MAKE) check
	find ../e/ -name '*.yaml' | xargs rm -v
	rm -fv ../k/*/kustomization.yaml
	c gen
