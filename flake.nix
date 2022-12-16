{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.14?dir=dev;
  };

  outputs = inputs: inputs.dev.main {
    inherit inputs;

    src = ./.;

    config = rec {
      slug = "amanibhavam-dotfiles";
      version = builtins.readFile ./VERSION;
    };

    handler = { pkgs, wrap, system, builders }: rec {
      defaultPackage = wrap.nullBuilder { };
    };
  };
}
