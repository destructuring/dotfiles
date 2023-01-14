{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.21?dir=dev;
    tired-proxy.url = github:defn/pkg/tired-proxy-0.0.4?dir=tired-proxy;
    moria.url = github:defn/pkg/moria-0.0.1?dir=moria;
  };

  outputs = inputs: inputs.dev.main rec {
    inherit inputs;

    src = builtins.path { path = ./.; name = config.slug; };

    config = rec {
      slug = builtins.readFile ./SLUG;
      version = builtins.readFile ./VERSION;
    };

    handler = { pkgs, wrap, system, builders }: rec {
      defaultPackage = wrap.bashBuilder {
        inherit src;

        installPhase = ''
          mkdir -p $out/bin
          cp nix-* $out/bin/
        '';

        propagatedBuildInputs = with pkgs; [
          inputs.tired-proxy.defaultPackage.${system}
          inputs.moria.defaultPackage.${system}
          curl
        ];
      };
    };
  };
}
