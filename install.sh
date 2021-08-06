#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo "installing aliases"

mkdir -p $HOME/.config

ln -sf $DIR/config/aliases $HOME/.config/aliases

echo "installing environment variables"
ln -sf $DIR/config/variables $HOME/.config/variables
source $HOME/.config/variables

echo "installing git files"

ln -sf $DIR/gitconfig $HOME/.gitconfig
ln -sf $DIR/gitignore $HOME/.gitignore

echo "install tmux conf"

ln -sf $DIR/tmux.conf $HOME/.tmux.conf

echo "install zsh"
mkdir -p $HOME/.config/zsh

ln -sf $DIR/config/zsh/zshrc $HOME/.config/zsh/.zshrc
ln -sf $DIR/zshenv $HOME/.zshenv


echo "install ssh"
mkdir -p $HOME/.ssh

chmod 700 ~/.ssh
ln -sf $DIR/ssh/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ln -sf $DIR/ssh/config $HOME/.ssh/config
chmod 644 ~/.ssh/config


ln -sf $DIR/ssh/rc $HOME/.ssh/rc
chmod 644 ~/.ssh/rc

./yed_install.sh
