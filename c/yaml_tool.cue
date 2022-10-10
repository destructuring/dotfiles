package c

import (
	"tool/file"
	"encoding/yaml"
)

// This makes the c wrapper happy.
command: {
	args: string @tag(args)
}

// Generate configs in e/ for Environments and ApplicationSets
command: gen: {
	genKustomizeYaml: {
		for kname, k in kustomize {
			// Configure kustomization.yaml
			// ex: argo-cd/kustomization.yaml
			"\(kname)-kustomization": file.Create & {
				filename: "../k/\(kname)/kustomization.yaml"
				contents: "#ManagedBy: cue\n\n" + yaml.Marshal(k.out)
			}

			for rname, r in k.resource {
				// Configure resources
				// ex: argoc-cd/resource-TYPE-NAME.yaml
				if r.kind != "" {
					"\(kname)-resource-\(rname)": file.Create & {
						filename: "../k/\(kname)/resource-\(rname).yaml"
						contents: "#ManagedBy: cue\n\n" + yaml.Marshal(r)
					}
				}
			}

			for pname, p in k.psm {
				// Configure patches
				// ex: argoc-cd/patch-NAME.yaml
				"\(kname)-patch-\(pname)": file.Create & {
					filename: "../k/\(kname)/patch-\(pname).yaml"
					contents: "#ManagedBy: cue\n\n" + yaml.Marshal(p)
				}
			}
		}
	}

	genEnvYaml: {
		for ename, e in env {
			// Configuration for K3D:
			// k3d -> [appset, appset, vcluster]
			if e.type == "k3d" {
				// ex: k3d-control.yaml
				"\(ename)-env": file.Create & {
					filename: "../e/\(e.env.metadata.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}

				// ex: k3d-control/k3d-control.yaml
				for aname, appset in e.appset {
					"\(ename)-appset-\(appset.metadata.name)": file.Create & {
						filename: "../e/\(e.env.metadata.name)/\(appset.metadata.name).yaml"
						contents: "# ManagedBy: cue\n\n" + yaml.Marshal(appset)
					}
				}
			}

			// Configuration for VCluster:
			// k3d -> [vcluster -> [appset, appset]]
			if e.type == "vcluster" {
				// ex: k3d-control/k3d-control-vc1.yaml
				"\(ename)-env": file.Create & {
					filename: "../e/\(e.machine.env.metadata.name)/\(e.machine.env.metadata.name)-\(e.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}

				// ex: vc1/vc1-vcluster.yaml
				"\(ename)-vcluster": file.Create & {
					filename: "../e/\(e.name)/\(e.name)-vcluster.yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.vcluster)
				}

				// ex: vc1/vc1.yaml
				for aname, appset in e.appset {
					"\(ename)-appset-\(appset.metadata.name)": file.Create & {
						filename: "../e/\(e.name)/\(e.name).yaml"
						contents: "# ManagedBy: cue\n\n" + yaml.Marshal(appset)
					}
				}
			}
		}
	}
}
