resource "kubernetes_service" "control" {
  metadata {
    name      = "control-0"
    namespace = "default"
  }

  spec {
    selector = {
      env = "control"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
}

data "kubernetes_config_map" "cluster_dns" {
  metadata {
    name      = "cluster-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_stateful_set" "dev" {
  for_each = var.envs

  metadata {
    name      = each.key
    namespace = "default"
  }

  wait_for_rollout = false

  spec {
    replicas = 1

    selector {
      match_labels = {
        env = each.key
        app = "dev"
      }
    }

    #    volume_claim_template {
    #      metadata {
    #        name = "work"
    #      }
    #      spec {
    #        access_modes = ["ReadWriteOnce"]
    #        resources {
    #          requests = {
    #            storage = "1G"
    #          }
    #        }
    #      }
    #    }

    template {
      metadata {
        labels = {
          env = each.key
          app = "dev"
        }
      }

      spec {
        dns_policy = "None"
        dns_config {
          #nameservers = [data.kubernetes_config_map.cluster_dns.data.clusterDNS]
          nameservers = ["127.0.0.1"]

          searches = ["default.svc.cluster.local", "svc.cluster.local", "cluster.local"]

          option {
            name  = "ndots"
            value = 5
          }
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "env"
                  operator = "In"
                  values   = [each.key]
                }
              }
            }
          }
        }

        toleration {
          key      = "env"
          operator = "Equal"
          value    = each.key
        }

        volume {
          name = "dind"
          empty_dir {}
        }

        volume {
          name = "earthly"
          host_path {
            path = "/mnt/earthly"
          }
        }

        volume {
          name = "docker"
          host_path {
            path = "/var/run/docker.sock"
          }
        }

        volume {
          name = "containerd"
          host_path {
            path = "/run/k3s/containerd"
          }
        }

        volume {
          name = "mntwork"
          host_path {
            path = "/mnt/work"
          }
        }

        volume {
          name = "tailscale"
          host_path {
            path = "/var/lib/tailscale/pod/var/lib/tailscale"
          }
        }

        volume {
          name = "tsrun"
          empty_dir {}
        }

        #        container {
        #          name              = "vscode-dev"
        #          image             = "${var.repo}workspace:latest"
        #          image_pull_policy = "Always"
        #
        #          command = ["/usr/bin/tini", "--"]
        #          args    = ["/usr/local/bin/code-server", "serve-local", "--accept-server-license-terms", "--disable-telemetry", "--without-connection-token", "--server-data-dir", "/work/vscode-server"]
        #
        #          tty = true
        #
        #          env {
        #            name  = "DEFN_DEV_HOST"
        #            value = each.value.host
        #          }
        #
        #          volume_mount {
        #            name       = "docker"
        #            mount_path = "/var/run/docker.sock"
        #          }
        #
        #          volume_mount {
        #            name       = "mntwork"
        #            mount_path = "/work"
        #          }
        #
        #          volume_mount {
        #            name       = "tsrun"
        #            mount_path = "/var/run/tailscale"
        #          }
        #
        #          security_context {
        #            privileged = true
        #          }
        #        }

        container {
          name              = "code-server"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "while true; do if test -S /var/run/tailscale/tailscaled.sock; then break; fi; sleep 1; done; sudo tailscale up --ssh --accept-dns=false --hostname=${each.key}-0; exec ~/bin/e code-server --bind-addr 0.0.0.0:8888 --disable-telemetry"]

          tty = true

          env {
            name  = "DEFN_DEV_HOST"
            value = each.value.host
          }

          env {
            name  = "PASSWORD"
            value = "admin"
          }

          volume_mount {
            name       = "docker"
            mount_path = "/var/run/docker.sock"
          }

          volume_mount {
            name       = "containerd"
            mount_path = "/run/containerd"
          }

          volume_mount {
            name       = "mntwork"
            mount_path = "/work"
          }

          volume_mount {
            name       = "tsrun"
            mount_path = "/var/run/tailscale"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name              = "tailscale"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["sudo", "tailscaled", "--statedir", "/var/lib/tailscale"]

          volume_mount {
            name       = "mntwork"
            mount_path = "/work"
          }

          volume_mount {
            name       = "tsrun"
            mount_path = "/var/run/tailscale"
          }

          volume_mount {
            name       = "tailscale"
            mount_path = "/var/lib/tailscale"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name              = "caddy"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "exec sudo caddy run"]

          volume_mount {
            name       = "mntwork"
            mount_path = "/work/dist"
            sub_path   = "dist"
          }

          volume_mount {
            name       = "tsrun"
            mount_path = "/var/run/tailscale"
          }
        }

        container {
          name              = "vault"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "exec ~/bin/e vault server -config etc/vault.yaml"]

          volume_mount {
            name       = "mntwork"
            mount_path = "/work"
          }
        }

        container {
          name              = "nomad"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "while true; do ts_ip=`tailscale ip -4 || true`; if test -n \"$ts_ip\"; then break; fi; sleep 1; done; exec ~/bin/e nomad agent -config=etc/nomad.conf -data-dir=/work/nomad -dc=grove -region=spiral -node=grove-0 -bootstrap-expect 1 -bind \"$ts_ip\""]

          volume_mount {
            name       = "mntwork"
            mount_path = "/work"
          }

          volume_mount {
            name       = "tsrun"
            mount_path = "/var/run/tailscale"
          }

          volume_mount {
            name       = "docker"
            mount_path = "/var/run/docker.sock"
          }
        }

        container {
          name              = "doh"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "exec ~/bin/e cloudflared proxy-dns --port 5553"]
        }

        container {
          name              = "coredns"
          image             = "${var.repo}workspace:latest"
          image_pull_policy = "Always"

          command = ["/usr/bin/tini", "--"]
          args    = ["bash", "-c", "exec sudo ~/bin/e coredns"]
        }

        container {
          name              = "buildkit"
          image             = "earthly/buildkitd:v0.6.24"
          image_pull_policy = "IfNotPresent"
          command           = ["sh", "-c"]
          args              = ["awk '/if.*rm.*data_root.*then/ {print \"rm -rf $data_root || true; data_root=/tmp/meh;\" }; {print}' /var/earthly/dockerd-wrapper.sh > /tmp/1 && chmod 755 /tmp/1 && mv -f /tmp/1 /var/earthly/dockerd-wrapper.sh; exec /usr/bin/entrypoint.sh buildkitd --config=/etc/buildkitd.toml"]
          tty               = true

          env {
            name  = "BUILDKIT_TCP_TRANSPORT_ENABLED"
            value = "true"
          }

          env {
            name  = "BUILDKIT_MAX_PARALLELISM"
            value = "4"
          }

          env {
            name  = "CACHE_SIZE_PCT"
            value = "90"
          }

          env {
            name  = "EARTHLY_ADDITIONAL_BUILDKIT_CONFIG"
            value = "[registry.\"169.254.32.1:5000\"]\n  http = true\n  insecure = true"
          }

          volume_mount {
            name       = "earthly"
            mount_path = "/tmp/earthly"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name              = "registry"
          image             = "registry:2"
          image_pull_policy = "IfNotPresent"
        }
      }
    }

    service_name = "dev"
  }
}

resource "kubernetes_cluster_role_binding" "dev" {
  metadata {
    name = "dev"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}
