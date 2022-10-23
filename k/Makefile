regen:
	for a in */; do (cd $$a && rm -rf charts && mkdir -p out && kustomize build --enable-helm > out/main.yaml); done