SHELL := /bin/bash

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

do: # Build DigitalOcean image
	env DIGITALOCEAN_TOKEN="$$(pass DIGITALOCEAN_TOKEN)" packer build -color=true -timestamp-ui=true $@.pkr.hcl

k3d/bin/k3d:
	-git clone https://github.com/amanibhavam/k3d
	cd k3d && make ci-setup build && chmod 755 bin/k3d

.tskey:
	pass k3d-control-tskey > $@.1
	mv $@.1 $@

.k3s-token:
	pass k3d-control-k3s-token > $@.1
	mv $@.1 $@

aws: k3d/bin/k3d .tskey .k3s-token
	env AWS_VAULT= aws-vault exec gyre-ops-sso -- packer build -color=true -timestamp-ui=true $@.pkr.hcl

fmt: # Format packer configs
	packer fmt -write=true .
