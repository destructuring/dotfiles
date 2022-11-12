{
  inputs = {
    dev.url = github:defn/pkg?dir=dev&ref=v0.0.22;
    temporalite-pkg.url = github:defn/pkg?dir=temporalite&ref=v0.0.4;
  };

  outputs = inputs:
    inputs.dev.wrapper.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.dev.wrapper.nixpkgs { inherit system; };
        wrap = inputs.dev.wrapper.wrap { other = inputs; inherit system; };
        slug = "defn-app";
        version = "0.0.1";
        buildInputs = [
        ];
      in
      rec {
        devShell = wrap.devShell;
        defaultPackage = pkgs.stdenv.mkDerivation
          rec {
            name = "${slug}-${version}";

            dontUnpack = true;

            installPhase = "mkdir -p $out";

            propagatedBuildInputs = buildInputs;

            meta = with pkgs.lib; {
              homepage = "https://defn.sh/${slug}";
              description = "nix golang / tilt integration";
              platforms = platforms.linux;
            };
          };
      }
    );
}
