{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.22?dir=dev;
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
      };
    };
  };
}
