dotfiles:
	mkdir -p .data/k .data/work
	mkdir -p .dotfiles/work
	git clone https://github.com/imma/junas .dotfiles/work/junas || true
	cd .dotfiles/work/junas && git submodule update --init
	ln -nfs .dotfiles/work/junas .vim
	ln -nfs .dotfiles/vimrc .vimrc
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	mkdir -p .config/pass-git-helper
	ln -nfs ../../.dotfiles/git-pass-mapping.ini .config/pass-git-helper/
	ln -nfs .data/work work
	ln -nfs .data/k/config .kube/config
