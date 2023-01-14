{
  inputs = {
    dev.url = github:defn/pkg/dev-0.0.22?dir=dev;
    tired-proxy.url = github:defn/pkg/tired-proxy-0.0.4?dir=tired-proxy;
    caddy.url = github:defn/pkg/caddy-2.6.2-5?dir=caddy;
    webhook.url = github:defn/pkg/webhook-2.8.0?dir=webhook;
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
          cp bin/* $out/bin/
        '';

        propagatedBuildInputs = [
          inputs.tired-proxy.defaultPackage.${system}
          inputs.caddy.defaultPackage.${system}
          inputs.webhook.defaultPackage.${system}
          pkgs.bashInteractive
          pkgs.curl
          pkgs.git
          pkgs.jq
        ];
      };

      packages = {
        this-gen-key = pkgs.writeShellScriptBin "this-gen-key" ''
          set -exfu

          nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem
          chmod 600 cache-priv-key.pem
        '';
      };

      devShell = wrap.devShell {
        devInputs = with packages; [
          this-gen-key
        ];
      };
    };
  };
}
