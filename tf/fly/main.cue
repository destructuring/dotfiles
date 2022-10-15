package fly

terraform: [{
	cloud: [{
		organization: "defn"
		workspaces: [{
			name: "fly"
		}]
	}]
}, {
	required_providers: [{
		fly: source: "fly-apps/fly"
	}]
}]

provider: fly: [{},
]

locals: [{
	flies: ["brie", "the", "so", "defn"]
}]

resource: {
	fly_app: dev: [{
		for_each: "${toset(local.flies)}"
		name:     "${each.key}"
		org:      "personal"
	}]

	fly_volume: dev: [{
		app:      "${fly_app.dev[each.key].name}"
		for_each: "${toset(local.flies)}"
		name:     "data"
		region:   "sjc"
		size:     1
	}]
}
