package c

import (
	core "github.com/defn/boot/k8s.io/api/core/v1"
	apps "github.com/defn/boot/k8s.io/api/apps/v1"
	rbac "github.com/defn/boot/k8s.io/api/rbac/v1"
)

kustomize: "vc1": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc1"
}

kustomize: "vc2": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc2"
}

kustomize: "vc3": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc3"
}

kustomize: "vc4": #KustomizeVCluster & {
	namespace: "vc1"
	vc_name:   "vc4"
}

kustomize: "argo-cd": #KustomizeHelm & {
	namespace: "argocd"

	helm: {
		release: "argocd"
		name:    "argo-cd"
		version: "5.5.11"
		repo:    "https://argoproj.github.io/argo-helm"
	}

	psm: "configmap-argocd-cm": core.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name: "argocd-cm"
		data: {
			"kustomize.buildOptions": "--enable-helm"
			"resource.customizations.health.networking.k8s.io_Ingress": """
				hs = {}
				hs.status = "Healthy"
				return hs

				"""

			"resource.customizations.ignoreDifferences.admissionregistration.k8s.io_MutatingWebhookConfiguration": """
				jsonPointers:
				  - /webhooks/0/clientConfig/caBundle
				  - /webhooks/0/rules

				"""

			"resource.customizations.ignoreDifferences.admissionregistration.k8s.io_ValidatingWebhookConfiguration": """
				jsonPointers:
				  - /webhooks/0/rules

				"""

			"resource.customizations.ignoreDifferences.apps_Deployment": """
				jsonPointers:
				  - /spec/template/spec/tolerations

				"""

			"resource.customizations.ignoreDifferences.kyverno.io_ClusterPolicy": """
				jqPathExpressions:
				  - .spec.rules[] | select(.name|test("autogen-."))

				"""
		}
	}
}

kustomize: "argo-events": #KustomizeHelm & {
	namespace: "argo-events"

	helm: {
		release: "argo-events"
		name:    "argo-events"
		version: "2.0.6"
		repo:    "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "argo-workflows": #KustomizeHelm & {
	helm: {
		release:   "argo-workflows"
		name:      "argo-workflows"
		namespace: "argo-workflows"
		version:   "0.20.1"
		repo:      "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "kyverno": #KustomizeHelm & {
	namespace: "kyverno"

	helm: {
		release: "kyverno"
		name:    "kyverno"
		version: "2.5.2"
		repo:    "https://kyverno.github.io/kyverno"
		values: {
			replicaCount: 1
		}
	}
}

kustomize: "keda": #KustomizeHelm & {
	namespace: "keda"

	helm: {
		release: "keda"
		name:    "keda"
		version: "2.8.2"
		repo:    "https://kedacore.github.io/charts"
	}
}

kustomize: "external-dns": #KustomizeHelm & {
	namespace: "external-dns"

	helm: {
		release: "external-dns"
		name:    "external-dns"
		version: "6.7.2"
		repo:    "https://charts.bitnami.com/bitnami"
		values: {
			sources: [
				"service",
				"ingress",
			]
			provider: "cloudflare"
		}
	}
}

kustomize: "external-secrets": #KustomizeHelm & {
	namespace: "external-secrets"

	helm: {
		release: "external-secrets"
		name:    "external-secrets"
		version: "0.5.8"
		repo:    "https://charts.external-secrets.io"
		values: {
			webhook: create:        false
			certController: create: false
		}
	}
}

kustomize: "datadog": #KustomizeHelm & {
	namespace: "datadog"

	helm: {
		release: "datadog"
		name:    "datadog"
		version: "3.1.1"
		repo:    "https://helm.datadoghq.com"
		values: {
			clusterAgent: {
				enabled: "true"
				metricsProvider: enabled: "true"
				processAgent: enabled:    "false"
			}
			targetSystem: "linux"
			datadog: {
				logs: {
					enabled:             true
					containerCollectAll: true
				}
				appKeyExistingSecret: "datadog-app-secret"
				apiKeyExistingSecret: "datadog-api-secret"
			}
		}
	}
}

kustomize: "kuma-global": #KustomizeHelm & {
	namespace: "kuma"

	helm: {
		release: "kuma"
		name:    "kuma"
		version: "1.8.0"
		repo:    "https://kumahq.github.io/charts"
		values: {
			controlPlane: {
				mode: "global"
				service: type: "LoadBalancer"
				tls: {
					general: {
						secretName: "generic-tls-certs"
						caBundle:   "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURiakNDQWxhZ0F3SUJBZ0lRU2lidDdEYnVsM0xoS0JreGxJaTY5REFOQmdrcWhraUc5dzBCQVFzRkFEQWkKTVNBd0hnWURWUVFERXhkcmRXMWhMV052Ym5SeWIyd3RjR3hoYm1VdWEzVnRZVEFlRncweU1qRXdNRFF3TmpRMwpNRFphRncwek1qRXdNREV3TmpRM01EWmFNQ0l4SURBZUJnTlZCQU1URjJ0MWJXRXRZMjl1ZEhKdmJDMXdiR0Z1ClpTNXJkVzFoTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFyWEdJaFY0WmtVLzcKZzJYa1dUbDJZcUl4eTFHTkcweWxQL0M3Q1hVZ2swNHpYQ0Z5Z3AyckxSRGtFVVBsVy8zNXJGcUFibmJVOUZhKwphTk0veTdvN2lCTlUzR0ozb042cXZoL0lIYmRVRDZHTENCYmRZWVpKVFZxK0IzSUQwZEZtOXd3WFlUQTlvSmJBCnJNcjhaK1J4TjhuY0xkcGZsTzZyVm5FT3F3aFpCVGUxQS93K3Vydk1kalZxSW1iVUl1anNxNDZVakcxaFpCQ0EKaXhIWXR4dGdrdVpqRXdtTXIyMEcyNjN3WmUzZ3pjWnoySnpNS2dSRHR5ZHNWYmNnWHJpOHpOSGNnWE1DSldiUApTeW9DNHZRcEc5UHV4K0NONmN1bVZCUjR4T1ZBbnlWUVFJQTc4MUI4b0JraEFrSmJ3N3lqaWpuM3BLQ0k4bnBsCjE2dVN2aVFkV1FJREFRQUJvNEdmTUlHY01BNEdBMVVkRHdFQi93UUVBd0lDcERBVEJnTlZIU1VFRERBS0JnZ3IKQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVdCQlFJMnEzUnB1UnRFZWdxdk9oSwp4T01sQVBRSGREQkZCZ05WSFJFRVBqQThnaGRyZFcxaExXTnZiblJ5YjJ3dGNHeGhibVV1YTNWdFlZSWJhM1Z0CllTMWpiMjUwY205c0xYQnNZVzVsTG10MWJXRXVjM1pqaHdSa1FHNFFNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUIKQVFBTXJteHhVOFRiUmtrZUhNU2lTS1dtc3piTXc0RW5NVTUvdEZiVHl2SG5RZVVSUHFQZmdycVEwdjhrWmUyQwpjb0lQWmxxK2xlU0V2TnR1UWNabVh4aW9abzJTdFlxT0gvZWVvVmk5V0x6VklmV2UwV1pDQUJ1WGlVYitDZ1YyClZnUTFITzU5QmdmTzgvVitPUFdMQ0xRVFBJaS94OGQydFRCMU1aVzRPWmhLOFV3NElnOVJ4MTdac2drTVRBY20KeTlIbCtIS3lzdktxVU5BelNRY3diQ1prdUpKVkdmUStoWjVhUmRSZXYyVkE3NlhXRmQ2RWJMYS9jZWhGNDZLSgpqKy9zVU1OOXhmYk1GTUE3T0l3aXJORTBzby9pRENIM1RNOHpsaXhBYm1XNUl4b3RXYXN3a0JoUTNiYTE2L3VkCjdmZ3ZmTFJRRkRQYW0xbEkraUNneTB1YwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
					}
					kdsGlobalServer: secretName: "kds-server-tls"
				}
			}
		}
	}
}

kustomize: "kuma-zone": #KustomizeHelm & {
	namespace: "kuma"

	helm: {
		release: "kuma"
		name:    "kuma"
		version: "1.8.0"
		repo:    "https://kumahq.github.io/charts"
		values: {
			controlPlane: {
				mode:             "zone"
				zone:             "control"
				kdsGlobalAddress: "grpcs://100.64.110.16:5685"
				tls: {
					general: {
						secretName: "kuma-tls-cert"
						caBundle:   "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhVENDQWxHZ0F3SUJBZ0lSQUw0cEVzblptNE9wSlBmTTg0MnlPYzB3RFFZSktvWklodmNOQVFFTEJRQXcKSWpFZ01CNEdBMVVFQXhNWGEzVnRZUzFqYjI1MGNtOXNMWEJzWVc1bExtdDFiV0V3SGhjTk1qSXhNREEwTURZMApPRFV5V2hjTk16SXhNREF4TURZME9EVXlXakFpTVNBd0hnWURWUVFERXhkcmRXMWhMV052Ym5SeWIyd3RjR3hoCmJtVXVhM1Z0WVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHRvdGFucnBGR1MKa0dSNVE0VVFMcDZvSktxOUpTSGwyTjhlZktrMGZUcytZK3lBL3puTlVHZ09rcmtYM0ZndXFmRTVGaE0xa1hHQQpEdzZNS1FnNzc1L3FreURsNDg0YmpPUmNLcHY5YWtqeHE4RHJYQ3YxNlpHbWZTVUZ1cExHRHBFS2VhSkRZZVBWCjB4TkpOS2RBWTBLWGdnTnczRmYzazBLYXgxNnFjdkMvVGhvODc5UFBybC9UTndmTVIvVzV4ZXIvUlZCaWdpUm0KQlJzVTYyWi9aRDliOTc3bjFoRjdHN2w0N1gwajM0dHB0Y2wrUDRPZ3NhenY2LzI3RGkrL09xRFlWT0xWdlJMaQpKRzdYVVcydmh5OC9lSDE2ZUR3US9YOGR5U0tTRlprOFZUWFBhbzkzMG9qN1EzQlB6dHhMZXZRSmRuL3dCdGMrCmIxSllKcGRwa3A4Q0F3RUFBYU9CbVRDQmxqQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0V3WURWUjBsQkF3d0NnWUkKS3dZQkJRVUhBd0V3RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFkQmdOVkhRNEVGZ1FVc1AzdEl6NU0yVkxieHpmdAowWWNqaDdSWHR4WXdQd1lEVlIwUkJEZ3dOb0lYYTNWdFlTMWpiMjUwY205c0xYQnNZVzVsTG10MWJXR0NHMnQxCmJXRXRZMjl1ZEhKdmJDMXdiR0Z1WlM1cmRXMWhMbk4yWXpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUlZSngKMFFPUDNvQktuWG5aUXlRMlUwNnQ0MkEyRmxwTnhzNWpFVEpXVGVHSXhzekhrMW5VYk9WZ0xLQUxKcjBlK1ArbQpwZlNzZitMaGhjZTMrbk01VHlaK3Z2bTc2L2xJL0lqUk9kNktSL2MrVmt6WjBrMFVJK0kzR1pVeUlpZVNuQkxpCmduMXFHRlZRSFZnOUQvMEVtZW54bkN3aUNqRzVwbkEyQm9aeCt4YTB6bG4zZHRLUUlXbTRzdU92UHFEa0tMM1AKMDZvRm9ndDlqSlQwNlNQNmNRY3VUeWYwMVdDQVozM25WajNDb05SQ2pKNThnMW9HQ2p2MmdXb3NSemlBVU5GLwpUN0kvQ2c3UWNxOVZ6Z3EwSEtGNXVyajNuYUVsOGRWMzhURDcvKzdjSmRhNDRkcHdRNWdldXV3RCtkVWdxd2Q5ClV0MlE1ZlFmd0dpbVo5bUxYUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
					}
					kdsZoneClient: secretName: "kds-ca-certs"
				}
			}
			ingress: enabled: true
			egress: enabled:  true
		}
	}
}

kustomize: "vault": #KustomizeHelm & {
	namespace: "vault"

	helm: {
		release: "vault"
		name:    "vault"
		version: "0.20.1"
		repo:    "https://helm.releases.hashicorp.com"
		values: {
			server: {
				dataStorage: size: "1Gi"
				standalone: config: """
					disable_mlock = true
					ui = true

					listener "tcp" {
					  tls_disable = 1
					  address = "[::]:8200"
					  cluster_address = "[::]:8201"
					}

					storage "file" {
					  path = "/vault/data"
					}

					seal "transit" {
					  address = "http://vault.default.svc:8200"
					  disable_renewal = "false"
					  key_name = "autounseal-remo"
					  mount_path = "transit/"
					  tls_skip_verify = "true"
					}

					"""
			}
		}
	}

	psm: "statefulset-vault-set-vault-token": {
		apiVersion: "apps/v1"
		kind:       "StatefulSet"
		metadata: {
			name:      "vault"
			namespace: "vault"
		}
		spec: template: spec: containers: [
			{name: "vault"
				env: [
					{
						name: "VAULT_TOKEN"
						valueFrom: secretKeyRef: {
							name: "vault-unseal"
							key:  "VAULT_TOKEN"
						}
					},
				]
			},
		]
	}
}

kustomize: "kong": #KustomizeHelm & {
	namespace: "kong"

	helm: {
		release: "kong"
		name:    "kong"
		version: "2.13.1"
		repo:    "https://charts.konghq.com"
		values: {
			enterprise: enabled: true
		}
	}

	psm: "service-kong-kong-proxy-set-cluster-ip": {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "kong-kong-proxy"
			namespace: "kong"
		}
		spec: type: "ClusterIP"
	}
}

kustomize: "arc": #KustomizeHelm & {
	namespace: "arc"

	helm: {
		release: "arc"
		name:    "actions-runner-controller"
		version: "0.21.0"
		repo:    "https://actions-runner-controller.github.io/actions-runner-controller"
	}

	resource: "runner-deployment-defn": {
		apiVersion: "actions.summerwind.dev/v1alpha1"
		kind:       "RunnerDeployment"
		metadata: name: "defn"
		spec: template: spec: {
			organization:                 "defn"
			dockerdWithinRunnerContainer: true
			image:                        "summerwind/actions-runner-dind"
		}
	}
}

kustomize: "kourier": #Kustomize & {
	resource: "kourier": {
		url: "https://github.com/knative-sandbox/net-kourier/releases/download/knative-v1.7.0/kourier.yaml"
	}

	psm: "service-kourier-set-cluster-ip": {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "kourier"
			namespace: "kourier-system"
		}
		spec: type: "ClusterIP"
	}
}

kustomize: "dev": #Kustomize & {
	namespace: "default"

	resource: "statefulset-dev": apps.#StatefulSet & {
		apiVersion: "apps/v1"
		kind:       "StatefulSet"
		metadata: {
			name:      "dev"
			namespace: "default"
		}
		spec: {
			serviceName: "dev"
			replicas:    1
			selector: matchLabels: app: "dev"
			template: {
				metadata: labels: app: "dev"
				spec: {
					volumes: [{
						name: "earthly"
						emptyDir: {}
					}, {
						name: "work"
						emptyDir: {}
					}]
					containers: [{
						name:            "buildkit"
						image:           "earthly/buildkitd:v0.6.25"
						imagePullPolicy: "IfNotPresent"
						command: [
							"sh",
							"-c",
						]
						args: [
							"awk '/if.*rm.*data_root.*then/ {print \"rm -rf $data_root || true; data_root=/tmp/meh;\" }; {print}' /var/earthly/dockerd-wrapper.sh > /tmp/1 && chmod 755 /tmp/1 && mv -f /tmp/1 /var/earthly/dockerd-wrapper.sh; exec /usr/bin/entrypoint.sh buildkitd --config=/etc/buildkitd.toml",
						]
						tty: true
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

						volumeMounts: [{
							mountPath: "/tmp/earthly"
							name:      "earthly"
						}]
						securityContext: privileged: true
					}, {
						name:            "code-server"
						image:           "169.254.32.1:5000/workspace"
						imagePullPolicy: "Always"
						command: [
							"/usr/bin/tini",
							"--",
						]
						args: [
							"bash",
							"-c",
							"exec ~/bin/e code-server --bind-addr 0.0.0.0:8888 --disable-telemetry",
						]
						tty: true
						env: [{
							name:  "PASSWORD"
							value: "admin"
						}]
						securityContext: privileged: true
						volumeMounts: [{
							mountPath: "/work"
							name:      "work"
						}]
					}]
				}
			}
		}
	}

	resource: "service-dev": core.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "dev"
			namespace: "default"
		}
		spec: {
			ports: [{
				port:       80
				protocol:   "TCP"
				targetPort: 8888
			}]
			selector: app: "dev"
			type: "ClusterIP"
		}
	}

	resource: "cluster-role-binding-dev": rbac.#ClusterRoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: name: "dev"
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cluster-admin"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "default"
			namespace: "default"
		}]
	}
}

kustomize: "karpenter": #KustomizeHelm & {
	namespace: "karpenter"

	helm: {
		release: "karpenter"
		name:    "karpenter"
		version: "0.16.3"
		repo:    "https://charts.karpenter.sh"
		values: {
			logLevel:        "error"
			clusterName:     "k3d-control"
			clusterEndpoint: "https://kubernetes.default.svc.cluster.local"
			controller: env: [{
				name:  "AWS_REGION"
				value: "us-west-1"
			}, {
				name:  "AWS_NODE_NAME_CONVENTION"
				value: "resource-name"
			}, {
				name: "AWS_ACCESS_KEY_ID"
				valueFrom: secretKeyRef: {
					name: "karpenter-aws"
					key:  "AWS_ACCESS_KEY_ID"
				}
			}, {
				name: "AWS_SECRET_ACCESS_KEY"
				valueFrom: secretKeyRef: {
					name: "karpenter-aws"
					key:  "AWS_SECRET_ACCESS_KEY"
				}
			}, {
				name: "AWS_SESSION_TOKEN"
				valueFrom: secretKeyRef: {
					name: "karpenter-aws"
					key:  "AWS_SESSION_TOKEN"
				}
			}]
		}
	}

	resource: "provisioner-vc1": {
		apiVersion: "karpenter.sh/v1alpha5"
		kind:       "Provisioner"
		metadata: name: "vc1"
		spec: {
			requirements: [{
				key:      "karpenter.sh/capacity-type"
				operator: "In"
				values: ["spot"]
			}, {
				key:      "kubernetes.io/arch"
				operator: "In"
				values: ["amd64"]
			}, {
				key:      "node.kubernetes.io/instance-type"
				operator: "In"
				values: ["t3.medium", "t3a.medium"]
			}]
			limits: resources: cpu: "2"
			labels: env: "vc1"
			taints: [{
				key:    "env"
				value:  "vc1"
				effect: "NoSchedule"
			}]
			providerRef: name: "default"
			ttlSecondsAfterEmpty: 600
		}
	}

	resource: "provisioner-vc2": {
		apiVersion: "karpenter.sh/v1alpha5"
		kind:       "Provisioner"
		metadata: name: "vc2"
		spec: {
			requirements: [{
				key:      "karpenter.sh/capacity-type"
				operator: "In"
				values: ["spot"]
			}, {
				key:      "kubernetes.io/arch"
				operator: "In"
				values: ["amd64"]
			}, {
				key:      "node.kubernetes.io/instance-type"
				operator: "In"
				values: ["m3.medium", "m1.medium", "t3.medium", "t3a.medium"]
			}]
			limits: resources: cpu: "2"
			labels: env: "vc2"
			taints: [{
				key:    "env"
				value:  "vc2"
				effect: "NoSchedule"
			}]
			providerRef: name: "default"
			ttlSecondsAfterEmpty: 1800
		}
	}
}

kustomize: "knative": #Kustomize & {
	resource: "knative-serving": {
		url: "https://github.com/knative/serving/releases/download/knative-v1.7.2/serving-core.yaml"
	}

	psm: "namespace-knative-serving": core.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: "knative-serving"
			labels: "kuma.io/sidecar-injection": "disabled"
		}
	}

	psm: "config-map-config-defaults": core.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name: "config-defaults"
		}
		data: {
			"revision-timeout-seconds":     "1800"
			"max-revision-timeout-seconds": "1800"
		}
	}

	psm: "config-map-config-domain": core.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name: "config-domain"
		}
		data: "svc.cluster.local": ""
	}

	psm: "config-map-config-features": core.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name: "config-features"
		}
		data: {
			"kubernetes.podspec-affinity":    "enabled"
			"kubernetes.podspec-tolerations": "enabled"
		}
	}

	psm: "config-map-config-network": core.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name: "config-network"
		}
		data: "ingress-class": "kourier.ingress.networking.knative.dev"
	}
}

kustomize: "cert-manager": #KustomizeHelm & {
	helm: {
		release:   "cert-manager"
		name:      "cert-manager"
		namespace: "cert-manager"
		version:   "1.9.1"
		repo:      "https://charts.jetstack.io"
	}

	resource: "cert-manager-crds": {
		url: "https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml"
	}
}
