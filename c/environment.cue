package c

env: (#Transform & {
	transformer: #TransformVClusterMachine

	inputs: [string]: #VClusterMachineInput
	inputs: {
		"global-vc0": {
			instance_types: []
			parent: env.global
		}

		"control-vc0": {
			instance_types: []
			parent: env.control
		}
		"control-vc1": {
			parent: env.control
		}
		"control-vc2": {
			parent: env.control
		}
		"control-vc3": {
			parent: env.control
		}
		"control-vc4": {
			parent: env.control
		}

		[N=string]: {
			bootstrap: {
				"cert-manager": 1
			}
		}
	}
}).outputs

env: (#Transform & {
	transformer: #TransformK3DMachine

	#CommonServices: {
		"cert-manager":              1
		"pod-identity-webhook":      10
		"kyverno":                   10
		"external-secrets-operator": 10
		"tfo":                       20
	}

	inputs: [string]: #EnvBootstrapInput
	inputs: {
		// global is the global control plane, used by all machines.
		global: {
			bootstrap: {
				"argo-cd": 0
				#CommonServices
			}
		}

		// control is the control plane, used by the operator.
		control: {
			bootstrap: {
				#CommonServices
			}
		}

		// smiley is the second machine used for multi-cluster.
		smiley: {
			bootstrap: {
				#CommonServices
			}
		}
	}
}).outputs

bootstrap: (#Transform & {
	transformer: #TransformEnvBootstrapToBootstrapMachine

	inputs: [string]: #EnvBootstrapInput
	inputs: {
		for _env_name, _env in env {
			"\(_env_name)": {
				name:      _env_name
				type:      _env.type
				bootstrap: _env.bootstrap
			}
		}
	}
}).outputs

kustomize: (#Transform & {
	transformer: #TransformVClusterToKustomize

	inputs: [string]: #VClusterInput
	inputs: {
		"control-vc0": {
			vc_machine: "control"
		}

		"global-vc0": {
			vc_machine: "global"
		}
	}
}).outputs

kustomize: (#Transform & {
	transformer: #TransformVClusterToKustomize

	inputs: [string]: #VClusterInput
	inputs: {
		"control-vc1": {}
		"control-vc2": {}
		"control-vc3": {}
		"control-vc4": {}
	}
}).outputs

kustomize: (#Transform & {
	transformer: #TransformEnvToAnyResource

	inputs: [string]: #EnvInput
	inputs: {
		for _env_name, _env in env {
			"\(_env_name)": {
				name:  _env_name
				type:  _env.type
				label: "\(type)-\(name)"
			}
		}
	}
}).outputs

kustomize: (#Transform & {
	transformer: #TransformEnvToSecretStore

	inputs: [string]: #EnvInput
	inputs: {
		for _env_name, _env in env {
			"\(_env_name)": {
				name:  _env_name
				type:  _env.type
				label: "\(type)-\(name)-secrets-store"
			}
		}
	}
}).outputs
