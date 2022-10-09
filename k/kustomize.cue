package kustomize

kustomize: "argo-cd": {
	helm: {
		release:   "argocd"
		name:      "argo-cd"
		namespace: "argocd"
		version:   "5.5.11"
		repo:      "https://argoproj.github.io/argo-helm"
	}

	psm: "configmap-argocd-cm": {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name: "argocd-cm"
		data: {
			"kustomize.buildOptions": "--enable-helm"
			"resource.customizations.health.networking.k8s.io_Ingress": """
				hs = {}
				hs.status = \"Healthy\"
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
				  - .spec.rules[] | select(.name|test(\"autogen-.\"))

				"""
		}
	}
}

kustomize: "argo-events": {
	helm: {
		release:   "argo-events"
		name:      "argo-events"
		namespace: "argo-events"
		version:   "2.0.6"
		repo:      "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "argo-workflows": {
	helm: {
		release:   "argo-workflows"
		name:      "argo-workflows"
		namespace: "argo-workflows"
		version:   "0.20.1"
		repo:      "https://argoproj.github.io/argo-helm"
	}
}

kustomize: "kyverno": {
	helm: {
		release:   "kyverno"
		name:      "kyverno"
		namespace: "kyverno"
		version:   "2.5.2"
		repo:      "https://kyverno.github.io/kyverno"
		values: {
			replicaCount: 1
		}
	}
}

kustomize: "vc1": #KustomizeVCluster & {
	vc_name: "vc1"
}

kustomize: "vc2": #KustomizeVCluster & {
	vc_name: "vc2"
}

kustomize: "vc3": #KustomizeVCluster & {
	vc_name: "vc3"
}

kustomize: "vc4": #KustomizeVCluster & {
	vc_name: "vc4"
}

kustomize: "keda": {
	helm: {
		release:   "keda"
		name:      "keda"
		namespace: "keda"
		version:   "2.8.2"
		repo:      "https://kedacore.github.io/charts"
	}
}

kustomize: "external-dns": {
	helm: {
		release:   "external-dns"
		name:      "external-dns"
		namespace: "external-dns"
		version:   "6.7.2"
		repo:      "https://charts.bitnami.com/bitnami"
		values: {
			sources: [
				"service",
				"ingress",
			]
			provider: "cloudflare"
		}
	}
}

kustomize: "external-secrets": {

	helm: {
		release:   "external-secrets"
		name:      "external-secrets"
		namespace: "external-secrets"
		version:   "0.5.8"
		repo:      "https://charts.external-secrets.io"
		values: {
			webhook: create:        false
			certController: create: false
		}
	}
}

kustomize: "datadog": {

	helm: {
		release:   "datadog"
		name:      "datadog"
		namespace: "datadog"
		version:   "3.1.1"
		repo:      "https://helm.datadoghq.com"
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

kustomize: "kuma-global": {
	helm: {
		release:   "kuma"
		name:      "kuma"
		namespace: "kuma"
		version:   "1.8.0"
		repo:      "https://kumahq.github.io/charts"
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

kustomize: "kuma-remote": {
	helm: {
		release:   "kuma"
		name:      "kuma"
		namespace: "kuma"
		version:   "1.8.0"
		repo:      "https://kumahq.github.io/charts"
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
