SHELL := /bin/bash

update:
	git pull && git submodule update --init
	cd .dotfiles && git pull && git submodule update --init
	$(MAKE) dotfiles

dotfiles:
	mkdir -p .dotfiles/work
	git clone https://github.com/imma/junas .dotfiles/work/junas || true
	cd .dotfiles/work/junas && git submodule update --init
	ln -nfs .dotfiles/work/junas .vim
	ln -nfs .dotfiles/vimrc .vimrc
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	ln -nfs .dotfiles/gitignore .gitignore
	ln -nfs .dotfiles/Makefile Makefile
	mkdir -p .ssh && chmod 700 .ssh
	chmod 600 .dotfiles/authorized_keys & ln -nfs ../.dotfiles/authorized_keys .ssh/authorized_keys
	mkdir -p .gnupg && chmod 700 .gnupg
	ln -nfs ../.dotfiles/gnupg/pubring.kbx .gnupg/pubring.kbx
	ln -nfs ../.dotfiles/gnupg/trustdb.gpg .gnupg/trustdb.gpg
	mkdir -p .aws
	if [[ -f /efs/config/aws/config ]]; then ln -nfs /efs/config/aws/config .aws/config; fi
	if [[ -f /efs/config/pass ]]; then ln -nfs /efs/config/pass /app/src/.password-store; fi
	source ./.bash_profile && $(MAKE) install

install:
	rm -f /usr/local/bin/kubectl
	brew bundle
	asdf install
	python -m venv venv
	source venv/bin/activate && pip install --no-cache-dir -r requirements.txt
