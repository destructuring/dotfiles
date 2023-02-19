{
  inputs = {
    pkg.url = github:defn/pkg/0.0.166;
    tired-proxy.url = github:defn/lib/tired-proxy-0.0.1?dir=cmd/tired-proxy;
    moria.url = github:defn/lib/moria-0.0.1?dir=cmd/moria;
  };

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
        ctx.pkgs.curl
        inputs.tired-proxy.defaultPackage.${ctx.system}
        inputs.moria.defaultPackage.${ctx.system}
      ];
    };
  };
}
