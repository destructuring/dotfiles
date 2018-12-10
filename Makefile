dotfiles:
	mkdir -p .dotfiles/work
	git clone https://github.com/imma/junas .dotfiles/work/junas
	cd .dotfiles/work/junas && git submodule update --init
	ln -nfs .dotfiles/work/junas .vim
	ln -nfs .dotfiles/vimrc .vimrc
