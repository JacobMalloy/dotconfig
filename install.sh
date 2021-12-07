#!/bin/bash
CC=gcc
CCFlags="-O2"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $(uname) = "Darwin" ]; then
    if uname -a | grep "arm64" >/dev/null 2>&1; then
        CCFlags+=" -arch arm64"
    fi
fi

YED="yes"
YED_CORE_COMMAND="--core-install"
YED_YPM_UPDATE="--ypm-update"

for var in "$@"
do
    case "$var" in
    "--no-yed")
    YED="no"
    ;;
    "--no-yed-core")
    YED_CORE_COMMAND=""
    ;;
    "--no-ypm-update")
    YED_YPM_UPDATE=""
    ;;
    *)
    printf "options are:\n--no-yed\n--no-yed-core\n--no-ypm-update\n"
    exit 1
    ;;
    esac
done


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

$CC $CCFlags $DIR/config/mem-cpu.c -o $HOME/.config/jacob-performance
ln -sf $DIR/tmux.conf $HOME/.tmux.conf

echo "install zsh"
mkdir -p $HOME/.config/zsh

ln -f $DIR/config/zsh/zshrc $HOME/.config/zsh/.zshrc
ln -f $DIR/zshenv $HOME/.zshenv

echo "install bashrc"
ln -f $DIR/bashrc $HOME/.bashrc


echo "install ssh"
mkdir -p $HOME/.ssh

chmod 700 ~/.ssh
ln -f $DIR/ssh/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ln -f $DIR/ssh/config $HOME/.ssh/config
chmod 644 ~/.ssh/config


ln -f $DIR/ssh/rc $HOME/.ssh/rc
chmod 644 ~/.ssh/rc

echo "installing kitty"
mkdir -p $HOME/.config/kitty
ln -sf $DIR/config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf


if [ "${YED}" != "no" ]; then
    ./yed_install.sh $YED_CORE_COMMAND $YED_YPM_UPDATE
fi
