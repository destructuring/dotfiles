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
			if e.type == "k3d" {
				"\(ename)-env": file.Create & {
					filename: "\(e.env.metadata.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}
			}

			if e.type == "vcluster" {
				"\(ename)-env": file.Create & {
					filename: "\(e.k3d.env.metadata.name)/\(e.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}

				"\(ename)-vcluster": file.Create & {
					filename: "\(e.name)/vcluster.yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.vcluster)
				}

				"\(ename)-appset": file.Create & {
					filename: "\(e.name)/appset.yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.appset)
				}
			}
		}
	}
}
