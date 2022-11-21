{
  inputs = {
    dev.url = "github:defn/pkg?dir=dev&ref=v0.0.56";
    c.url = "github:defn/pkg?dir=c&ref=v0.0.56";
    flyctl.url = "github:defn/pkg?dir=flyctl&ref=v0.0.56";
    argocd.url = "github:defn/pkg?dir=argocd&ref=v0.0.56";
    tf.url = "github:defn/pkg?dir=tf&ref=v0.0.60";
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

          defaultPackage = wrap.nullBuilder {
            propagatedBuildInputs = with pkgs; [
              kubernetes-helm
              kustomize
              terraform
            ];
          };
        };
    };
}
