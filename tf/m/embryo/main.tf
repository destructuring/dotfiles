provider "kubernetes" {}

resource "kubernetes_namespace" "egg" {
  metadata {
    name = "embryo"
  }
}