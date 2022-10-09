package env

import (
	"tool/file"
	"encoding/yaml"
)

command: {
	args: string @tag(args)
}

command: gen: {
	genYaml: {
		for ename, e in env {
			// Configuration for a K3D machine
			// k3d -> [appset, appset, vcluster]
			if e.type == "k3d" {
				// ex: k3d-control.yaml
				"\(ename)-env": file.Create & {
					filename: "\(e.env.metadata.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}

				// ex: k3d-control/k3d-control.yaml
				for aname, appset in e.appset {
					"\(ename)-appset-\(appset.metadata.name)": file.Create & {
						filename: "\(e.env.metadata.name)/\(appset.metadata.name).yaml"
						contents: "# ManagedBy: cue\n\n" + yaml.Marshal(appset)
					}
				}
			}

			// Configuration for a Vcluster machine.
			// k3d -> [vcluster -> [appset, appset]]
			if e.type == "vcluster" {
				// ex: k3d-control/k3d-control-vc1.yaml
				"\(ename)-env": file.Create & {
					filename: "\(e.k3d.env.metadata.name)/\(e.k3d.env.metadata.name)-\(e.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}

				// ex: vc1/cluster.yaml
				"\(ename)-vcluster": file.Create & {
					filename: "\(e.name)/vcluster.yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.vcluster)
				}

				// ex: vc1/appset.yaml
				for aname, appset in e.appset {
					"\(ename)-appset-\(appset.metadata.name)": file.Create & {
						filename: "\(e.name)/appset.yaml"
						contents: "# ManagedBy: cue\n\n" + yaml.Marshal(appset)
					}
				}
			}
		}
	}
}
