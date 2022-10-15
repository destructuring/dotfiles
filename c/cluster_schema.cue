package c

cluster: [NAME=string]: #Cluster & {cluster_name: NAME}

#Cluster: ctx={
	cluster_name: string
	k3d_name:     string | *"k3d-\(cluster_name)"
	domain:       string | *"tiger-mamba.ts.net"
	mpath:        string | *"../m"

	locals: [...{...}] | *[{envs: {}}]
	module: [string]: [...{...}]

	out: {
		provider: kubernetes: [{
			config_context: k3d_name
			config_path:    "~/.kube/config"
		}]

		locals: ctx.locals

		module: ctx.module
	}
}
