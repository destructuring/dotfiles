package c

import (
	"tool/file"
	"encoding/yaml"
)

// This makes the c wrapper happy.
command: {
	args: string @tag(args)
}

command: gen: {
	genKustomizeYaml: {
		for kname, k in kustomize {
			// Configure kustomization.yaml
			// ex: k/argo-cd/kustomization.yaml
			"\(kname)-kustomization": file.Create & {
				filename: "../k/\(kname)/kustomization.yaml"
				contents: "#ManagedBy: cue\n\n" + yaml.Marshal(k.out)
			}

			for rname, r in k.resource {
				// Configure resources
				// ex: k/argoc-cd/resource-TYPE-NAME.yaml
				if r.kind != "" {
					"\(kname)-resource-\(rname)": file.Create & {
						filename: "../k/\(kname)/resource-\(rname).yaml"
						contents: "#ManagedBy: cue\n\n" + yaml.Marshal(r)
					}
				}
			}

			for pname, p in k.psm {
				// Configure patches
				// ex: k/argoc-cd/patch-NAME.yaml
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
			// env application -> bootstrap
			if e.type == "k3d" {
				// ex: e/k3d-control.yaml
				"\(ename)-env": file.Create & {
					filename: "../e/\(e.env.metadata.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}
			}
		}
	}
}
