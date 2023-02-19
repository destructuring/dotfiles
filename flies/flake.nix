{
  inputs = {
    pkg.url = github:defn/pkg/0.0.165;
    kubernetes.url = github:defn/pkg/kubernetes-0.0.8?dir=kubernetes;
    cloud.url = github:defn/pkg/cloud-0.0.3?dir=cloud;
    terraform.url = github:defn/pkg/terraform-1.4.0-beta2-1?dir=terraform;
  };

  outputs = inputs: inputs.pkg.main rec {
    src = ./.;

    config = {
      flies = [
        "brie"
        "so"
        "the"
        "wh"
        "wx"
        "defn"
      ];
    };

    devShell = ctx: ctx.wrap.devShell {
      devInputs = [
        (defaultPackage ctx)
      ];
    };

    defaultPackage = ctx: ctx.wrap.nullBuilder {
      propagatedBuildInputs =
        let
          flakeInputs = [
            inputs.kubernetes.defaultPackage.${ctx.system}
            inputs.cloud.defaultPackage.${ctx.system}
            inputs.terraform.defaultPackage.${ctx.system}
          ];
        in
        flakeInputs
        ++ ctx.commands
        ++ (map (name: (packages ctx).${name}) config.flies);
    };

    packages = ctx: ctx.pkgs.lib.genAttrs config.flies (name:
      ctx.pkgs.writeShellScriptBin "${name}" ''
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
}
