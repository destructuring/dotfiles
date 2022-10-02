variable "scripts1" {
  type = list(string)
  default = [
    "script/000-install-bare",
    "script/001-install-base",
  ]
}

variable "scripts2" {
  type = list(string)
  default = [
    "script/990-defn-dev",
    "script/999-update"
  ]
}

source "digitalocean" "this" {
  image            = "ubuntu-20-04-x64"
  region           = "sfo3"
  size             = "c-2"
  snapshot_name    = "defn-dev"
  snapshot_regions = []
  ssh_username     = "root"
}

build {
  sources = ["source.digitalocean.this"]

  provisioner "file" {
    source      = "k3d/bin/k3d"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/k3d /usr/local/bin/"
    ]
  }

  provisioner "shell" {
    scripts = var.scripts1
  }

  provisioner "shell" {
    scripts = var.scripts2
  }
}
