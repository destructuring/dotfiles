genkey:
	env PRIV_KEY="sa-signer.key" PUB_KEY="sa-signer.key.pub" PKCS_KEY="sa-signer-pkcs8.pub" $(MAKE) genkey-inner

genkey-inner:
		ssh-keygen -t rsa -b 2048 -f $$PRIV_KEY -m pem
		ssh-keygen -e -m PKCS8 -f $$PUB_KEY > $$PKCS_KEY
