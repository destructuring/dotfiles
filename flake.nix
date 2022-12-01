{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.4?dir=dev;
  };

  outputs = inputs:
    inputs.dev.main {
      inherit inputs;

      config =
        rec {
          slug = "defn-app";
          version_src = ./VERSION;
          version = builtins.readFile version_src;
        };

      handler = { pkgs, wrap, system }:
        rec {
          devShell = wrap.devShell;
          defaultPackage = wrap.nullBuilder { };
        };
    };
}
