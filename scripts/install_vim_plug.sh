#/bin/sh

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.vim/colors/
curl -o ~/.vim/colors/zenburn.vim https://raw.githubusercontent.com/jnurmine/Zenburn/refs/heads/master/colors/zenburn.vim

