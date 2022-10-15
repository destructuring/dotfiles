cp:
	env KUMA_MODE=zone KUMA_MULTIZONE_ZONE_NAME=pod KUMA_MULTIZONE_ZONE_GLOBAL_ADDRESS=grpcs://100.64.110.16:5685 KUMA_MULTIZONE_ZONE_KDS_ROOT_CA_FILE=$$HOME/app/k/k3d-circus-secrets/kuma-global-ca.crt kuma-cp run

dp:
	-sudo useradd meh
	sudo rm -f /tmp/dev-token /tmp/kuma-al-dev-default.sock
	kumactl generate dataplane-token | sudo sudo -u meh tee /tmp/dev-token >/dev/null
	sudo sudo -u meh kuma-dp run --cp-address=https://100.103.25.109:5678 --dataplane-token-file=/tmp/dev-token --dataplane-file=dev-dp.yaml

ingress:
	sudo rm -f /tmp/ingress-token
	kumactl generate zone-ingress-token --zone=pod > /tmp/ingress-token
	kuma-dp run --proxy-type=ingress --cp-address=https://100.103.25.109:5678 --dataplane-token-file=/tmp/ingress-token --dataplane-file=ingress-dp.yaml

tp:
	$(MAKE) untp
	#sudo kumactl install transparent-proxy --kuma-dp-user ubuntu --exclude-outbound-ports 5678 --exclude-inbound-ports 80,443,8000,8888
	sudo iptables-restore --noflush iptables.txt

untp:
	sudo kumactl uninstall transparent-proxy