dotfiles:
	mkdir -p .dotfiles/work
	git clone https://github.com/imma/junas .dotfiles/work/junas || true
	cd .dotfiles/work/junas && git submodule update --init
	ln -nfs .dotfiles/work/junas .vim
	ln -nfs .dotfiles/vimrc .vimrc
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	ln -nfs .dotfiles/tool-versions .tool-versions
	ln -nfs .dotfiles/gitignore .gitignore
	ln -nfs .dotfiles/Makefile Makefile
	ln -nfs .dotfiles/Brewfile .dotfiles/Brewfile.lock.json .
	ln -nfs .dotfiles/requirements.txt .dotfiles/requirements.in .
	ln -nfs ../.dotfiles/gnupg/pubring.kbx .gnupg/pubring.kbx
	ln -nfs ../.dotfiles/gnupg/trustdb.gpg .gnupg/trustdb.gpg
