package tf

data: kubernetes_config_map: cluster_dns: [{
	metadata: [{
		name:      "cluster-dns"
		namespace: "kube-system"
	}]
}]
resource: {
	kubernetes_cluster_role_binding: dev: [{
		metadata: [{
			name: "dev"
		}]
		role_ref: [{
			api_group: "rbac.authorization.k8s.io"
			kind:      "ClusterRole"
			name:      "cluster-admin"
		}]
		subject: [{
			kind:      "ServiceAccount"
			name:      "default"
			namespace: "default"
		}]
	}]
	kubernetes_service: control: [{
		metadata: [{
			name:      "control-0"
			namespace: "default"
		}]
		spec: [{
			port: [{
				name:        "http"
				port:        80
				target_port: 80
			}, {
				name:        "https"
				port:        443
				target_port: 443
			}]
			selector: env: "control"
			type: "LoadBalancer"
		}]
	}]
	kubernetes_stateful_set: dev: [{
		for_each: "${var.envs}"
		metadata: [{
			name:      "${each.key}"
			namespace: "default"
		}]
		spec: [{
			replicas: 1
			selector: [{
				match_labels: {
					app: "dev"
					env: "${each.key}"
				}
			}]
			service_name: "dev"
			template: [{
				metadata: [{
					annotations: {
						"kuma.io/gateway":           "enabled"
						"kuma.io/sidecar-injection": "disabled"
					}
					labels: {
						app: "dev"
						env: "${each.key}"
					}
				}]
				spec: [{
					affinity: [{
						node_affinity: [{
							required_during_scheduling_ignored_during_execution: [{
								node_selector_term: [{
									match_expressions: [{
										key:      "env"
										operator: "In"
										values: ["${each.key}"]
									}]
								}]
							}]
						}]
					}]
					container: [{
						args: ["bash", "-c", "while true; do if test -S /var/run/tailscale/tailscaled.sock; then break; fi; sleep 1; done; sudo tailscale up --ssh --accept-dns=false --hostname=${each.key}-0; exec ~/bin/e code-server --bind-addr 0.0.0.0:8888 --disable-telemetry"]
						command: ["/usr/bin/tini", "--"]
						env: [{
							name:  "DEFN_DEV_HOST"
							value: "${each.value.host}"
						}, {
							name:  "PASSWORD"
							value: "admin"
						}]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "code-server"
						security_context: [{
							privileged: true
						}]
						tty: true
						volume_mount: [{
							mount_path: "/var/run/docker.sock"
							name:       "docker"
						}, {
							mount_path: "/run/containerd"
							name:       "containerd"
						}, {
							mount_path: "/work"
							name:       "mntwork"
						}, {
							mount_path: "/var/run/tailscale"
							name:       "tsrun"
						}]
					}, {
						args: ["sudo", "tailscaled", "--statedir", "/var/lib/tailscale"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "tailscale"
						security_context: [{
							privileged: true
						}]
						volume_mount: [{
							mount_path: "/work"
							name:       "mntwork"
						}, {
							mount_path: "/var/run/tailscale"
							name:       "tsrun"
						}, {
							mount_path: "/var/lib/tailscale"
							name:       "tailscale"
						}]
					}, {
						args: ["bash", "-c", "exec sudo caddy run"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "caddy"
						volume_mount: [{
							mount_path: "/work/dist"
							name:       "mntwork"
							sub_path:   "dist"
						}, {
							mount_path: "/var/run/tailscale"
							name:       "tsrun"
						}]
					}, {
						args: ["bash", "-c", "exec ~/bin/e vault server -config etc/vault.yaml"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "vault"
						volume_mount: [{
							mount_path: "/work"
							name:       "mntwork"
						}]
					}, {
						args: ["bash", "-c", "exec ~/bin/e nomad agent -config=etc/nomad.conf -data-dir=/work/nomad -dc=dev -region=circus -node=`uname -n` -bootstrap-expect 1"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "nomad"
						volume_mount: [{
							mount_path: "/work"
							name:       "mntwork"
						}, {
							mount_path: "/var/run/tailscale"
							name:       "tsrun"
						}, {
							mount_path: "/var/run/docker.sock"
							name:       "docker"
						}]
					}, {
						args: ["bash", "-c", "exec ~/bin/e cloudflared proxy-dns --port 5553"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "cloudflared"
					}, {
						args: ["bash", "-c", "exec sudo ~/bin/e coredns"]
						command: ["/usr/bin/tini", "--"]
						image:             "${var.repo}workspace:latest"
						image_pull_policy: "Always"
						name:              "coredns"
					}, {
						args: ["exec /usr/local/bin/dockerd-entrypoint.sh --storage-driver overlay2 --mtu=`ifconfig eth0 | grep MTU | awk '{print $5}' | cut -d: -f2`"]
						command: ["sh", "-c"]
						env: [{
							name:  "DOCKER_TLS_CERTDIR"
							value: ""
						}]
						image:             "docker:dind"
						image_pull_policy: "IfNotPresent"
						name:              "dind"
						security_context: [{
							privileged: true
						}]
						volume_mount: [{
							mount_path: "/var/lib/docker"
							name:       "dind"
						}]
					}, {
						args: ["awk '/if.*rm.*data_root.*then/ {print \"rm -rf $data_root || true; data_root=/tmp/meh;\" }; {print}' /var/earthly/dockerd-wrapper.sh > /tmp/1 && chmod 755 /tmp/1 && mv -f /tmp/1 /var/earthly/dockerd-wrapper.sh; exec /usr/bin/entrypoint.sh buildkitd --config=/etc/buildkitd.toml"]
						command: ["sh", "-c"]
						env: [{
							name:  "BUILDKIT_TCP_TRANSPORT_ENABLED"
							value: "true"
						}, {
							name:  "BUILDKIT_MAX_PARALLELISM"
							value: "4"
						}, {
							name:  "CACHE_SIZE_PCT"
							value: "90"
						}, {
							name: "EARTHLY_ADDITIONAL_BUILDKIT_CONFIG"
							value: """
																[registry."169.254.32.1:5000"]
																  http = true
																  insecure = true
																"""
						}]
						image:             "earthly/buildkitd:v0.6.26"
						image_pull_policy: "IfNotPresent"
						name:              "buildkit"
						security_context: [{
							privileged: true
						}]
						tty: true
						volume_mount: [{
							mount_path: "/tmp/earthly"
							name:       "earthly"
						}]
					}, {
						image:             "registry:2"
						image_pull_policy: "IfNotPresent"
						name:              "registry"
						volume_mount: [{
							mount_path: "/var/lib/registry"
							name:       "registry"
						}]
					}]
					dns_config: [{
						nameservers: ["127.0.0.1"]
						option: [{
							name:  "ndots"
							value: 5
						}]
						searches: ["default.svc.cluster.local", "svc.cluster.local", "cluster.local"]
					}]
					dns_policy: "None"
					toleration: [{
						key:      "env"
						operator: "Equal"
						value:    "${each.key}"
					}]
					volume: [{
						host_path: [{
							path: "/mnt/registry"
						}]
						name: "registry"
					}, {
						host_path: [{
							path: "/mnt/dind"
						}]
						name: "dind"
					}, {
						host_path: [{
							path: "/mnt/earthly"
						}]
						name: "earthly"
					}, {
						host_path: [{
							path: "/var/run/docker.sock"
						}]
						name: "docker"
					}, {
						host_path: [{
							path: "/run/k3s/containerd"
						}]
						name: "containerd"
					}, {
						host_path: [{
							path: "/mnt/work"
						}]
						name: "mntwork"
					}, {
						host_path: [{
							path: "/var/lib/tailscale/pod/var/lib/tailscale"
						}]
						name: "tailscale"
					}, {
						empty_dir: [{}]
						name: "tsrun"
					}]
				}]
			}]
		}]
		wait_for_rollout: false
	}]
}
