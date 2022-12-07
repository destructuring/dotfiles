{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.8?dir=dev;
  };

  outputs = inputs: inputs.dev.main {
    inherit inputs;

    config = rec {
      slug = "defn-app";
      version = builtins.readFile ./VERSION;
    };

    handler = { pkgs, wrap, system }: rec {
      devShell = wrap.devShell { };
      defaultPackage = wrap.nullBuilder { };
    };
  };
}
