package c

cluster: circus: {}

cluster: smiley: {}

cluster: control: ctx={
	locals: [{
		envs: control: {
			domain: ctx.domain
			host:   ctx.k3d_name
		}
	}]

	module: devpod: [{
		envs:   "${local.envs}"
		source: "\(ctx.mpath)/devpod"
	}]
}
