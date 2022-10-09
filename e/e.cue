package env

#EnvApp: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"

	metadata: {
		namespace: "argocd"
		name:      string
	}

	spec: {
		project: "default"

		destination: name: "in-cluster"
		source: {
			repoURL:        "https://github.com/defn/app"
			targetRevision: "master"
			path:           string
		}

		syncPolicy?: automated?: prune?: bool
	}
}

#AppSet: {
	_name:   string
	_prefix: string | *""
	_suffix: string | *""

	apiVersion: "argoproj.io/v1alpha1"
	kind:       "ApplicationSet"

	metadata: {...}
	metadata: {
		name:      "\(_prefix)\(_name)\(_suffix)"
		namespace: "argocd"
	}

	spec: {...}
}

#K3D: ctx={
	type: "k3d"
	name: string

	env: #EnvApp & {
		metadata: {
			name: "k3d-\(ctx.name)"
		}

		spec: {
			source: path: "e/k3d-\(ctx.name)"

			syncPolicy: automated: prune: true
		}
	}

	appset: [string]: #AppSet
}

#VCluster: ctx={
	type: "vcluster"
	name: string

	k3d: #K3D

	env: #EnvApp & {
		metadata: {
			name: "\(k3d.env.metadata.name)-\(ctx.name)"
		}
		spec: {
			source: path: "e/\(ctx.name)"
		}
	}

	vcluster: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"
		metadata: {
			name:      "\(ctx.name)-vcluster"
			namespace: "argocd"
		}
		spec: {
			project: "default"
			source: {
				repoURL:        "https://github.com/defn/app"
				path:           "k/\(ctx.name)"
				targetRevision: "master"
			}
			destination: {
				namespace: ctx.name
				name:      "in-cluster"
			}
			syncPolicy: syncOptions: ["CreateNamespace=true"]
		}
	}

	appset: default: #AppSet & {

		metadata: {
			name: ctx.name
		}
		spec: {
			generators: [{
				list: elements: [{
					name:      "dev"
					namespace: "default"
					path:      "dev"
					cluster:   ctx.name
				}]
			}]
			template: {
				metadata: {
					name:      "\(ctx.name)-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: {
						namespace: "{{namespace}}"
						name:      "{{cluster}}"
					}
					syncPolicy: syncOptions: ["CreateNamespace=true"]
				}
			}
		}
	}
}

env: [NAME=string]: name: NAME
env: [NAME=string]: appset: [string]: _name: NAME
env: [NAME=string]: #K3D | #VCluster

env: control: #K3D & {
	appset: default: {
		_prefix: "k3d-"
		metadata: {
			name:      "k3d-control"
			namespace: "argocd"
		}
		spec: {
			generators: [{
				list: elements: [{
					name:      "kyverno"
					namespace: "kyverno"
					path:      "kyverno"
					cluster:   "in-cluster"
				}, {
					name:      "cert-manager"
					namespace: "cert-manager"
					path:      "cert-manager"
					cluster:   "in-cluster"
				}, {
					name:      "external-secrets"
					namespace: "external-secrets"
					cluster:   "in-cluster"
					path:      "external-secrets"
				}, {
					name:      "argo-cd"
					namespace: "argocd"
					cluster:   "in-cluster"
					path:      "argo-cd"
				}, {
					name:      "argo-events"
					namespace: "argo-events"
					cluster:   "in-cluster"
					path:      "argo-events"
				}, {
					name:      "argo-workflows"
					namespace: "argo-workflows"
					cluster:   "in-cluster"
					path:      "argo-workflows"
				}, {
					name:      "knative"
					namespace: "knative-serving"
					cluster:   "in-cluster"
					path:      "knative"
				}]
			}]
			template: {
				metadata: {
					name:      "k3d-control-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: {
						namespace: "{{namespace}}"
						name:      "{{cluster}}"
					}
					syncPolicy: {
						syncOptions: [
							"CreateNamespace=true",
						]
						automated: prune: true
					}
					ignoreDifferences: [{
						group: ""
						kind:  "Secret"
						jsonPointers: [
							"/data",
							"/data/ca-cert.pem",
							"/data/server-cert.pem",
							"/data/server-key.pem",
						]
						name:      "karpenter-cert"
						namespace: "karpenter"
					}]
				}
			}
		}
	}

	appset: nons: {
		_prefix: "k3d-"
		_suffix: "-nons"

		spec: {
			generators: [{
				list: elements: [{
					name:    "kourier"
					path:    "kourier"
					cluster: "in-cluster"
				}]
			}]
			template: {
				metadata: {
					name:      "k3d-control-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: name: "{{cluster}}"
					syncPolicy: {
						syncOptions: [
							"CreateNamespace=true",
						]
						automated: prune: true
					}
				}
			}
		}
	}
}

env: circus: #K3D & {
	appset: default: {
		_prefix: "k3d-"

		spec: {
			generators: [{
				list: elements: [{
					name:      "kyverno"
					namespace: "kyverno"
					path:      "kyverno"
					cluster:   "k3d-circus"
				}, {
					name:      "cert-manager"
					namespace: "cert-manager"
					path:      "cert-manager"
					cluster:   "k3d-circus"
				}, {
					name:      "kuma-global"
					namespace: "kuma"
					path:      "kuma-global"
					cluster:   "k3d-circus"
				}]
			}]
			template: {
				metadata: {
					name:      "k3d-circus-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: {
						namespace: "{{namespace}}"
						name:      "{{cluster}}"
					}
					syncPolicy: {
						syncOptions: [
							"CreateNamespace=true",
						]
						automated: prune: true
					}
					ignoreDifferences: [{
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "vault-agent-injector-cfg"
						jsonPointers: [
							"/webhooks/0/clientConfig/caBundle",
						]
					}, {
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "webhook.domainmapping.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "webhook.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "ValidatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "validation.webhook.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "ValidatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "validation.webhook.domainmapping.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "Deployment"
						group: "apps"
						name:  "kong-kong"
						jsonPointers: [
							"/spec/template/spec/tolerations",
						]
					}, {
						group: "kyverno.io"
						kind:  "ClusterPolicy"
						jqPathExpressions: [".spec.rules[] | select(.name|test(\"autogen-.\"))"]
					}]
				}
			}
		}
	}
}

env: smiley: #K3D & {
	appset: default: {
		_prefix: "k3d-"

		spec: {
			generators: [{
				list: elements: [{
					name:      "kyverno"
					namespace: "kyverno"
					path:      "kyverno"
					cluster:   "k3d-smiley"
				}, {
					name:      "cert-manager"
					namespace: "cert-manager"
					path:      "cert-manager"
					cluster:   "k3d-smiley"
				}]
			}]
			template: {
				metadata: {
					name:      "k3d-smiley-{{name}}"
					namespace: "argocd"
				}
				spec: {
					project: "default"
					source: {
						repoURL:        "https://github.com/defn/app"
						path:           "k/{{path}}"
						targetRevision: "master"
					}
					destination: {
						namespace: "{{namespace}}"
						name:      "{{cluster}}"
					}
					syncPolicy: {
						syncOptions: [
							"CreateNamespace=true",
						]
						automated: prune: true
					}
					ignoreDifferences: [{
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "vault-agent-injector-cfg"
						jsonPointers: [
							"/webhooks/0/clientConfig/caBundle",
						]
					}, {
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "webhook.domainmapping.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "MutatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "webhook.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "ValidatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "validation.webhook.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "ValidatingWebhookConfiguration"
						group: "admissionregistration.k8s.io"
						name:  "validation.webhook.domainmapping.serving.knative.dev"
						jsonPointers: [
							"/webhooks/0/rules",
						]
					}, {
						kind:  "Deployment"
						group: "apps"
						name:  "kong-kong"
						jsonPointers: [
							"/spec/template/spec/tolerations",
						]
					}, {
						group: "kyverno.io"
						kind:  "ClusterPolicy"
						jqPathExpressions: [".spec.rules[] | select(.name|test(\"autogen-.\"))"]
					}]
				}
			}
		}
	}
}

env: vc1: #VCluster & {
	k3d: env.control
}

env: vc2: #VCluster & {
	k3d: env.control
}

env: vc3: #VCluster & {
	k3d: env.control
}

env: vc4: #VCluster & {
	k3d: env.control
}
