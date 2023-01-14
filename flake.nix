{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.19?dir=dev;
    kubectl.url = github:defn/pkg/kubectl-1.25.5-0?dir=kubectl;
    kustomize.url = github:defn/pkg/kustomize-4.5.7-3?dir=kustomize;
    helm.url = github:defn/pkg/helm-3.10.2-3?dir=helm;
    terraform.url = github:defn/pkg/terraform-1.3.6-4?dir=terraform;
    flyctl.url = github:defn/pkg/flyctl-0.0.450-0?dir=flyctl;
  };

  # main is nix sugar to cleanly confgure inputs, project config, and how to
  # handle shells/builds
  outputs = inputs: inputs.dev.main rec {
    inherit inputs;

    src = builtins.path { path = ./.; name = config.slug; };

    config = rec {
      slug = builtins.readFile ./SLUG;
      version = builtins.readFile ./VERSION;
      flies = [
        "brie"
        "so"
        "the"
        "wh"
        "flakes"
        "defn"
        "defn-dev-demo"
        "nomad-48530"
      ];
    };

    # get a dev shell and default package
    handler = { pkgs, wrap, system, builders }: rec {
      defaultPackage = wrap.nullBuilder {
        propagatedBuildInputs = map (name: packages.${name}) config.flies;
      };

      # scripts
      packages = pkgs.lib.genAttrs config.flies (name:
        pkgs.writeShellScriptBin "${name}" ''
          set -exfu

          case "''${1:-}" in
            deploy)
              cd ./$(git rev-parse --show-cdup)/flies/${name}
              time earthly --push --no-output +image --image=registry.fly.io/${name}:latest
              docker pull registry.fly.io/${name}:latest
              flyctl machine update -a ${name} --yes --dockerfile Dockerfile $(flyctl machine list -a ${name} --json | jq -r '.[].id')
              ;;
            *)
              exec flyctl -a ${name} "$@"
              ;;
          esac
        '');
    };
  };
}
