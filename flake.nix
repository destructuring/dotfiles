{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.22?dir=dev;
    kubectl.url = github:defn/pkg/kubectl-1.25.5-0?dir=kubectl;
    kustomize.url = github:defn/pkg/kustomize-4.5.7-3?dir=kustomize;
    helm.url = github:defn/pkg/helm-3.10.2-3?dir=helm;
    terraform.url = github:defn/pkg/terraform-1.3.6-4?dir=terraform;
    flyctl.url = github:defn/pkg/flyctl-0.0.450-0?dir=flyctl;
  };

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
        "wx"
        "wwwwww"
        "flakes"
        "defn"
      ];
    };

    # get a dev shell and default package
    handler = { pkgs, wrap, system, builders }: rec {
      devShell = wrap.devShell {
        devInputs = wrap.flakeInputs;
      };

      defaultPackage = wrap.nullBuilder {
        propagatedBuildInputs = map (name: packages.${name}) config.flies;
      };

      # scripts
      packages = pkgs.lib.genAttrs config.flies (name:
        pkgs.writeShellScriptBin "${name}" ''
          set -exfu

          case "''${1:-}" in
            build)
              cd ./$(git rev-parse --show-cdup)/flies/${name}
              time earthly --push --no-output +image --image=registry.fly.io/${name}:latest
              docker pull registry.fly.io/${name}:latest
              ;;
            deploy)
              cd ./$(git rev-parse --show-cdup)/flies/${name}
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
