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
			"\(ename)": file.Create & {
				filename: "\(e.metadata.name).yaml"
				contents: "# ManagedBy: cue\n\n" + yaml.Marshal(e)
			}
		}
	}
}
