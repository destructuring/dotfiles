package c

cluster: [string]: #Cluster

#Cluster: ctx={
	cluster_name: string
	k3d_name:     "k3d-\(cluster_name)"
	domain:       "tiger-mamba.ts.net"

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
