domain ?= $(shell tailscale cert 2>&1 | grep 'For domain' | cut -d'"' -f2)

.PHONY: so the brie

so the brie:
	rm -rf tmp
	mkdir tmp
	mkdir -p tmp/$@/var/lib/tailscale
	(cd tmp/$@ && pass tailscale_$@ | base64 -d | tar xvf -)
	-flyctl secrets set -a $@ --detach \
		DEFN_DEV_ARCHIVE="$$(cd tmp/$@ && tar cvf - . | base64 | xargs | sed 's# ##g')" \
		DEFN_DEV_HOST="$@.$(domain)" \
		PASSWORD="$$(pass pass-code-server)"
	rm -rf tmp
	flyctl deploy -a $@ --remote-only --config app.toml

up:
	flyctl scale count 1 -a $(shell basename $(PWD))

down:
	flyctl scale count 0 -a $(shell basename $(PWD))

proxy-docker:
	while true; do flyctl --app "$(shell flyctl apps list | grep 'fly-builder' | awk '{print $$1}' | head -1)" proxy 2375:2375; sleep 1; done

prune:
	flyctl apps list | grep fly-builder | head -n1 | awk '{print $$1;}' | xargs echo flyctl ssh console --command "docker system prune --force" --app
