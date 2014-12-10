#!/bin/bash

mv dev.vim /usr/share/vim/vim74/colors/dev.vim

echo "
set tabstop=4
set shiftwidth=4
set expandtab
set background=dark
colorscheme dev" >> /etc/vimrc

yum groupinstall 'Development Tools'
