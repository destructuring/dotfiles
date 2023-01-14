package c

import (
	"tool/file"
	"encoding/json"
)

command: gen: {
	genTerraform: {
		"flies": file.Create & {
			filename: "main.tf.json"
			contents: json.Marshal({terraform, "//": "ManagedBy: cue"})
		}
	}
}
