package tf

variable: {
	envs: [{
		default: {}
	}]

	repo: [{
		default: "169.254.32.1:5000/"
	}]
}

data: kubernetes_config_map: cluster_dns: [{
	metadata: [{
		name:      "cluster-dns"
		namespace: "kube-system"
	}]
}]

#TTY: {
	tty: true
}

#Privileged: {
	security_context: [{
		privileged: true
	}]
}

#LocalDNS: {
	dns_policy: "None"
	dns_config: [{
		nameservers: ["127.0.0.1"]
		option: [{
			name:  "ndots"
			value: 5
		}]
		searches: ["default.svc.cluster.local", "svc.cluster.local", "cluster.local"]
	}]
}

#NodeAffinity: {
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

	toleration: [{
		key:      "env"
		operator: "Equal"
		value:    "${each.key}"
	}]
}

#Volumes: {
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
}

#ContainerCodeServer: {
	name:              "code-server"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "while true; do if test -S /var/run/tailscale/tailscaled.sock; then break; fi; sleep 1; done; sudo tailscale up --ssh --accept-dns=false --hostname=${each.key}-0; exec ~/bin/e code-server --bind-addr 0.0.0.0:8888 --disable-telemetry"]

	#TTY
	#Privileged

	volume_mount: [#MountDocker, #MountContainerd, #MountWork, #MountTailscaleRun]

	env: [{
		name:  "DEFN_DEV_HOST"
		value: "${each.value.host}"
	}, {
		name:  "PASSWORD"
		value: "admin"
	}]
}

#ContainerTailscale: {
	name:              "tailscale"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["sudo", "tailscaled", "--statedir", "/var/lib/tailscale"]

	#Privileged

	volume_mount: [#MountWork, #MountTailscaleRun, #MountTailscaleState]
}

#ContainerCaddy: {
	name:              "caddy"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "exec sudo caddy run"]

	volume_mount: [#MountDist, #MountTailscaleRun]
}

#ContainerVault: {
	name:              "vault"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "exec ~/bin/e vault server -config etc/vault.yaml"]

	volume_mount: [#MountWork]
}

#ContainerNomad: {
	name:              "nomad"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "exec ~/bin/e nomad agent -config=etc/nomad.conf -data-dir=/work/nomad -dc=dev -region=circus -node=`uname -n` -bootstrap-expect 1"]

	volume_mount: [#MountWork, #MountTailscaleRun, #MountDocker]
}

#ContainerCloudflared: {
	name:  "cloudflared"
	image: "${var.repo}workspace:latest"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "exec ~/bin/e cloudflared proxy-dns --port 5553"]
	image_pull_policy: "Always"
}

#ContainerCoreDNS: {
	name:              "coredns"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "exec sudo ~/bin/e coredns"]
}

#ContainerDIND: {
	name:              "dind"
	image:             "docker:dind"
	image_pull_policy: "IfNotPresent"
	command: ["sh", "-c"]
	args: ["exec /usr/local/bin/dockerd-entrypoint.sh --storage-driver overlay2 --mtu=`ifconfig eth0 | grep MTU | awk '{print $5}' | cut -d: -f2`"]

	#Privileged

	volume_mount: [#MountDIND]

	env: [{
		name:  "DOCKER_TLS_CERTDIR"
		value: ""
	}]
}

#ContainerBuildKit: {
	name:              "buildkit"
	image:             "earthly/buildkitd:v0.6.26"
	image_pull_policy: "IfNotPresent"
	command: ["sh", "-c"]
	args: ["awk '/if.*rm.*data_root.*then/ {print \"rm -rf $data_root || true; data_root=/tmp/meh;\" }; {print}' /var/earthly/dockerd-wrapper.sh > /tmp/1 && chmod 755 /tmp/1 && mv -f /tmp/1 /var/earthly/dockerd-wrapper.sh; exec /usr/bin/entrypoint.sh buildkitd --config=/etc/buildkitd.toml"]

	#TTY
	#Privileged

	volume_mount: [#MountEarthly]

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
}

#ContainerRegistry: {
	name:              "registry"
	image:             "registry:2"
	image_pull_policy: "IfNotPresent"

	volume_mount: [#MountRegistry]
}

#ContainerKumaCP: {
	name:              "kuma-cp"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "~/bin/e ~/bin/kuma-cp-on"]

	volume_mount: [#MountTailscaleRun]
}

#ContainerKumaIngress: {
	name:              "kuma-ingress"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "~/bin/e ~/bin/kuma-ingress-on"]
}

#ContainerKumaDP: {
	name:              "kuma-dp"
	image:             "${var.repo}workspace:latest"
	image_pull_policy: "Always"
	command: ["/usr/bin/tini", "--"]
	args: ["bash", "-c", "~/bin/e ~/bin/kuma-dp-on"]
}

#MountDocker: {
	mount_path: "/var/run/docker.sock"
	name:       "docker"
}
#MountContainerd: {
	mount_path: "/run/containerd"
	name:       "containerd"
}

#MountWork: {
	mount_path: "/work"
	name:       "mntwork"
}
#MountTailscaleRun: {
	mount_path: "/var/run/tailscale"
	name:       "tsrun"
}

#MountTailscaleState: {
	mount_path: "/var/lib/tailscale"
	name:       "tailscale"
}

#MountDist: {
	mount_path: "/work/dist"
	name:       "mntwork"
	sub_path:   "dist"
}

#MountDIND: {
	mount_path: "/var/lib/docker"
	name:       "dind"
}

#MountEarthly: {
	mount_path: "/tmp/earthly"
	name:       "earthly"
}

#MountRegistry: {
	mount_path: "/var/lib/registry"
	name:       "registry"
}

resource: kubernetes_stateful_set: dev: [{
	for_each: "${var.envs}"

	wait_for_rollout: false

	metadata: [{
		name:      "${each.key}"
		namespace: "default"
	}]

	spec: [{
		service_name: "dev"
		replicas:     1

		selector: [{
			match_labels: {
				app: "dev"
				env: "${each.key}"
			}
		}]

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
				#LocalDNS

				#NodeAffinity

				#Volumes

				container: [
					#ContainerCodeServer,

					#ContainerVault,
					#ContainerNomad,

					#ContainerCaddy,

					#ContainerBuildKit,
					#ContainerRegistry,
					#ContainerDIND,

					#ContainerTailscale,
					#ContainerCoreDNS,
					#ContainerCloudflared,

					#ContainerKumaCP,
					#ContainerKumaIngress,
				]
			}]
		}]
	}]
}]

resource: kubernetes_cluster_role_binding: dev: [{
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

resource: kubernetes_service: control: [{
	metadata: [{
		name:      "control-0"
		namespace: "default"
	}]

	spec: [{
		selector: env: "control"
		type: "LoadBalancer"

		port: [{
			name:        "http"
			port:        80
			target_port: 80
		}, {
			name:        "https"
			port:        443
			target_port: 443
		}]
	}]
}]
