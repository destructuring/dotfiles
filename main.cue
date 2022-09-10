package app

import (
	"github.com/defn/boot/project"
)

#AppContext: {
	project.#Project
}

appContext: #AppContext & {
	codeowners: ["@jojomomojo", "@amanibhavam"]
}
