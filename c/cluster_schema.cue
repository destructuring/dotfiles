package c

cluster: [NAME=string]: #Cluster & {cluster_name: NAME}

fly: [NAME=string]: #Fly & {fly_name: NAME}

flies: #Flies

#Cluster: ctx={
	cluster_name: string
	k3d_name:     string | *"k3d-\(cluster_name)"
	domain:       string
	mpath:        string
	kube_config:  string | *"~/.kube/config"

	// Passthrough Terraform locals, module config
	locals: [...{...}] | *[{envs: {}}]
	module: [string]: [...{...}]

	// Terraform hcl.json output
	out: {
		terraform: backend: kubernetes: [{
			secret_suffix:  "state-\(k3d_name)"
			config_path:    "~/.kube/config"
			config_context: k3d_name
		}]

		provider: kubernetes: [{
			config_context: k3d_name
			config_path:    kube_config
		}]

		locals: ctx.locals

		if len(ctx.module) > 0 {
			module: ctx.module
		}
	}
}

#DevPod: ctx=#Cluster & {
	// Configure cluster
	locals: [{
		envs: "\(ctx.cluster_name)": {
			domain: ctx.domain
			host:   ctx.k3d_name
		}
	}]

	// Deploy a dev pod with the above configuration
	module: devpod: [{
		source: "\(ctx.mpath)/devpod"
		envs:   "${local.envs}"
	}]
}

#Flies: {
	flies: [...#Fly]
	flies: [
		for f in fly {f},
	]

	// Terraform hcl.json output
	out: {
		provider: fly: [{}]

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

		for f in flies {
			f.out
		}

	}
}

#Fly: {
	fly_name:      string
	fly_org:       string | *"personal"
	fly_region:    string
	fly_size:      int | *1
	fly_data_name: string | *"data"

	// Terraform hcl.json output
	out: {
		resource: {
			fly_app: "\(fly_name)": [{
				name: fly_name
				org:  fly_org
			}]

			fly_volume: "\(fly_name)": [{
				app:    "${fly_app.\(fly_name).name}"
				name:   fly_data_name
				region: fly_region
				size:   fly_size
			}]
		}
	}
}
