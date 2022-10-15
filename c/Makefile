SHELL := /bin/bash

check:
	cue fmt
	cue eval -c >/dev/null

gen:
	$(MAKE) check
	find ../e/ -name '*.yaml' | xargs rm -f
	rm -f ../k/*/kustomization.yaml
	rm -f ../k/*/resource-*.yaml
	rm -f ../k/*/patch-*.yaml
	rm -f ../tf/*/*.tf.json
	c gen
	git add ../e ../k ../tf
	pc || true
	git add ../e ../k ../tf
