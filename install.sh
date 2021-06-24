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


echo "install ssh"
mkdir -p $HOME/.ssh

chmod 700 ~/.ssh
ln -sf $PWD/ssh/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ln -sf $PWD/ssh/config $HOME/.ssh/config
chmod 644 ~/.ssh/config
