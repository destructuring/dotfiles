SHELL := /bin/bash

gen:
	cue fmt
	cue eval -c
	rm -f *.yaml */*.yaml
	c gen
