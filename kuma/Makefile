mesh:
	global apply -f universal.yaml

cp:
	env KUMA_MODE=zone KUMA_MULTIZONE_ZONE_NAME=pod KUMA_MULTIZONE_ZONE_GLOBAL_ADDRESS=grpcs://100.64.110.16:5685 KUMA_MULTIZONE_ZONE_KDS_ROOT_CA_FILE=$$HOME/app/k/kuma-global/ca.crt kuma-cp run

ingress:
	kumactl generate zone-ingress-token --zone=pod > /tmp/ingress-token
	kuma-dp run --proxy-type=ingress --cp-address=https://100.103.25.109:5678 --dataplane-token-file=/tmp/ingress-token --dataplane-file=ingress-dp.yaml
