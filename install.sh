#!/bin/bash

echo "installing aliases"

mkdir -p $HOME/.config

ln -sf $PWD/config/aliases $HOME/.config/aliases

echo "installing git files"

ln -sf $PWD/gitconfig $HOME/.gitconfig
ln -sf $PWD/gitignore $HOME/.gitignore

echo "install tmux conf"

ln -sf $PWD/tmux.conf $HOME/.tmux.conf

echo "install zsh"
mkdir -p $HOME/.config/zsh

ln -sf $PWD/config/zsh/.zshrc $HOME/.config/zsh/.zshrc
ln -sf $PWD/zshenv $HOME/.zshenv