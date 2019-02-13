dotfiles:
	mkdir -p /data/k /data/work
	mkdir -p .dotfiles/work
	git clone https://github.com/imma/junas .dotfiles/work/junas || true
	cd .dotfiles/work/junas && git submodule update --init || true
	ln -nfs .dotfiles/work/junas .vim
	ln -nfs .dotfiles/vimrc .vimrc
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	ln -nfs /data/work work
	ln -nfs /data/k/config .kube/config
	cd aws && make
	chm nix install powerline-go figlet lolcat
	chm enable home

elixir:
	sudo apt-get install -y postgresql-client
	nix-env -i elixir
	mix local.rebar --force
	mix local.hex --force
	mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

rust:
	sudo pip3 install aws-sam-cli
	curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
	rustup target add x86_64-unknown-linux-musl
	rustup target add wasm32-unknown-unknown --toolchain nightly
	rustup component add rustfmt-preview
	cargo install --force wasm-pack cargo-generate

consulfs:
	go get github.com/bwester/consulfs/cmd/consulfs
	echo consulfs https://consul.chm.life ~/data/fs/consul
