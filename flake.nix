{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.2?dir=dev;
  };

  outputs = inputs:
    inputs.dev.main {
      inherit inputs;

      config =
        rec {
          slug = "defn-app";
          version = "0.0.1";
          homepage = "https://defn.sh/${slug}";
          description = "k8s applications";
        };

      handler = { pkgs, wrap, system }:
        rec {
          devShell = wrap.devShell;
          defaultPackage = wrap.nullBuilder { };
        };
    };
}
