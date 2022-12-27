package c

env: (#Transform & {
	transform: #TransformVClusterMachine
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
	transform: #TransformK3DMachine
	inputs: [string]: #K3DMachineInput

	#CommonServices: {
		"cert-manager":              1
		"pod-identity-webhook":      10
		"kyverno":                   10
		"external-secrets-operator": 10
		"tfo":                       30
	}

	inputs: {
		// global is the global control plane, used by all machines.
		global: {
			bootstrap: {
				"argo-cd":                  0
				"k3d-global-secrets-store": 20
				#CommonServices
			}
		}

		// control is the control plane, used by the operator.
		control: {
			bootstrap: {
				"k3d-global-secrets-store": 20
				#CommonServices
			}
		}

		// smiley is the second machine used for multi-cluster.
		smiley: {
			bootstrap: {
				"k3d-global-secrets-store": 20
				#CommonServices
			}
		}
	}
}).outputs

kustomize: (#Transform & {
	transform: #TransformVClusterToKustomize
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
	transform: #TransformVClusterToKustomize
	inputs: [string]: #VClusterInput

	inputs: {
		"control-vc1": {}
		"control-vc2": {}
		"control-vc3": {}
		"control-vc4": {}
	}
}).outputs

kustomize: (#Transform & {
	transform: #TransformEnvToAnyResourceKustomizeHelm
	inputs: [string]: #EnvInput

	inputs: {
		for ename, e in env {
			"\(ename)": {
				name:      ename
				type:      e.type
				label:     "\(type)-\(name)"
				bootstrap: e.bootstrap
			}
		}
	}
}).outputs

kustomize: (#Transform & {
	transform: #TransformEnvToSecretStoreKustomize
	inputs: [string]: #EnvInput

	inputs: {
		for ename, e in env {
			"\(ename)": {
				name:  ename
				type:  e.type
				label: "\(type)-\(name)-secrets-store"
			}
		}
	}
}).outputs
