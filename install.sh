#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo "installing aliases"

mkdir -p $HOME/.config

ln -f $DIR/config/aliases $HOME/.config/aliases

echo "installing environment variables"
ln -f $DIR/config/variables $HOME/.config/variables
source $HOME/.config/variables

echo "installing git files"

ln -f $DIR/gitconfig $HOME/.gitconfig
ln -f $DIR/gitignore $HOME/.gitignore

echo "install tmux conf"

ln -f $DIR/tmux.conf $HOME/.tmux.conf

echo "install zsh"
mkdir -p $HOME/.config/zsh

ln -f $DIR/config/zsh/zshrc $HOME/.config/zsh/.zshrc
ln -f $DIR/zshenv $HOME/.zshenv


echo "install ssh"
mkdir -p $HOME/.ssh

chmod 700 ~/.ssh
ln -f $DIR/ssh/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ln -f $DIR/ssh/config $HOME/.ssh/config
chmod 644 ~/.ssh/config


ln -f $DIR/ssh/rc $HOME/.ssh/rc
chmod 644 ~/.ssh/rc

./yed_install.sh
