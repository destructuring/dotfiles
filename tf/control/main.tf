provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-control"
}

module "devpod" {
  source = "../m/devpod"
  envs   = local.envs
  repo   = local.repo
}
