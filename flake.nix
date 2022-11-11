{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    dev.url = "github:defn/pkg?dir=dev&ref=v0.0.11";
    temporalite-pkg.url = "github:defn/pkg?dir=temporalite&ref=v0.0.4";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , dev
    , temporalite-pkg
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      temporalite = temporalite-pkg.defaultPackage.${system};
    in
    {
      devShell =
        pkgs.mkShell rec {
          buildInputs = with pkgs; [
            dev.defaultPackage.${system}
            temporalite
          ];
        };

      defaultPackage =
        with import nixpkgs { inherit system; };
        stdenv.mkDerivation rec {
          name = "${slug}-${version}";

          slug = "defn-app";
          version = "0.0.1";

          dontUnpack = true;

          installPhase = "mkdir -p $out";

          propagatedBuildInputs = [
          ];

          meta = with lib;
            {
              homepage = "https://defn.sh/${slug}";
              description = "nix golang / tilt integration";
              platforms = platforms.linux;
            };
        };
    });
}
