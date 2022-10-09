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
				"\(ename)": file.Create & {
					filename: "\(e.env.metadata.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}
			}

			if e.type == "vcluster" {
				"\(ename)": file.Create & {
					filename: "\(e.k3d.env.metadata.name)/\(e.name).yaml"
					contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e.env)
				}
			}
		}
	}
}
