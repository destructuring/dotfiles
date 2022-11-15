{
  inputs = {
    dev.url = "github:defn/pkg?dir=dev&ref=v0.0.56";
    c.url = "github:defn/pkg?dir=c&ref=v0.0.56";
    argocd.url = "github:defn/pkg?dir=argocd&ref=v0.0.56";
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
            propagatedBuildInputs = [
              pkgs.kubernetes-helm
              pkgs.kustomize
            ];
          };
        };
    };
}
