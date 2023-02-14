{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.23?dir=dev;
    terraform.url = github:defn/pkg/terraform-1.3.8-0?dir=terraform;
    kubernetes.url = github:defn/pkg/kubernetes-0.0.6?dir=kubernetes;
    cloud.url = github:defn/pkg/cloud-0.0.1?dir=cloud;
  };

  outputs = inputs: inputs.dev.main rec {
    inherit inputs;

    src = builtins.path { path = ./.; name = builtins.readFile ./SLUG; };

    config = rec {
      flies = [
        "brie"
        "so"
        "the"
        "wh"
        "wx"
        "defn"
      ];
    };

    # get a dev shell and default package
    handler = { pkgs, wrap, system, builders, commands, config }: rec {
      devShell = wrap.devShell {
        devInputs = [ defaultPackage ];
      };

      defaultPackage = wrap.nullBuilder {
        propagatedBuildInputs = wrap.flakeInputs ++ commands ++ (map (name: packages.${name}) config.flies);
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
