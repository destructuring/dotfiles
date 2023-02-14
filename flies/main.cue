package c

fly: [N=string]: #FlyApp & {
	fly_name:   N
	fly_image:  "ghcr.io/defn/dev:latest-fly"
	fly_region: "sjc"
}

#FlyDevEnv: #FlyApp & {
	fly_data_size: 20
	fly_mount:     "/nix"
	fly_memorymb:  2048
	fly_env: DOCKER_HOST: "tcp://localhost:2375"
	fly_services: [{
		protocol:      "tcp"
		internal_port: 80
		ports: [{
			port: 443
			handlers: ["http", "tls"]
		}]
	}]
}

fly: defn: #FlyDevEnv & {
	fly_machine_name: "defn1"
}

fly: brie: {
	fly_ip:           true
	fly_machine_name: "brie"
	fly_services: [{
		protocol:      "tcp"
		internal_port: 8000
		ports: [{
			port: 443
			handlers: ["http", "tls"]
		}]
	}]
}

fly: wh: {
	fly_ip:           true
	fly_machine_name: "defn2"
	fly_mount:     "/cache"
	fly_data_size: 10
	fly_cpus:      2
	fly_memorymb:  4096
	fly_services: [{
		protocol:      "tcp"
		internal_port: 8000
		ports: [{
			port: 443
			handlers: ["http", "tls"]
		}]
	}]
}

fly: wx: {
	fly_ip:           false
	fly_machine_name: "defn5"
	fly_services: []
}

fly: so: {
	fly_ip:           false
	fly_machine_name: "defn3"
	fly_services: []
}

fly: the: {
	fly_ip:           false
	fly_machine_name: "defn4"
	fly_services: []
}

terraform: {
	provider: fly: [{}]

	provider: random: [{}]

	terraform: [{
		required_providers: [{
			fly: source:    "fly-apps/fly"
			random: source: "hashicorp/random"
		}]

		cloud: {
			hostname:     "app.terraform.io"
			organization: "defn"
			workspaces: name: "fly-48530"
		}
	}]

	for f in fly {
		f.terraform
	}
}

#FlyApp: {
	fly_name:      string
	fly_org:       string | *"personal"
	fly_region:    string
	fly_data_size: int | *1
	fly_data_name: string | *"data"
	fly_ip:        bool | *false

	fly_machine:      bool | *true
	fly_machine_name: string
	fly_image:        string
	fly_env: [string]: string
	fly_services: [...]
	fly_mount:     string | *"/mnt"
	fly_encrypted: bool | *false
	fly_cpus:      int | *1
	fly_memorymb:  int | *256

	terraform: {
		resource: {
			fly_app: "\(fly_name)": [{
				name: fly_name
				org:  fly_org
			}]

			fly_volume: "\(fly_name)": [{
				app:    "${fly_app.\(fly_name).name}"
				name:   fly_data_name
				region: fly_region
				size:   fly_data_size
			}]

			if fly_ip == true {
				fly_ip: "\(fly_name)": [{
					app:  "${fly_app.\(fly_name).name}"
					type: "v4"
				}]
			}

			if fly_machine == true {
				fly_machine: "\(fly_name)": [{
					app:    "${fly_app.\(fly_name).name}"
					region: fly_region
					name:   fly_machine_name

					image: fly_image

					env:      fly_env
					services: fly_services

					mounts: [{
						path:      fly_mount
						volume:    "${fly_volume.\(fly_name).id}"
						encrypted: fly_encrypted
					}]

					cpus:     fly_cpus
					memorymb: fly_memorymb

					lifecycle: ignore_changes: [ "image"]
				}]
			}
		}
	}
}
