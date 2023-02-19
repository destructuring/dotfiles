{
  inputs.pkg.url = github:defn/pkg/0.0.166;

  outputs = inputs: inputs.pkg.main rec {
    src = ./.;

    defaultPackage = ctx: ctx.wrap.bashBuilder {
      inherit src;

      installPhase = ''
        mkdir -p $out/bin
        cp nix-* $out/bin/
      '';

      propagatedBuildInputs = [
        ctx.pkgs.bashInteractive
      ];
    };
  };
}
