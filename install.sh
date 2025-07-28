#!/usr/bin/env bash
CC=gcc
CCFlags="-O3"
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


echo "installing git files"

ln -sf $DIR/gitconfig $HOME/.gitconfig
ln -sf $DIR/gitignore $HOME/.gitignore

echo "Build tmux-performance"
$CC $CCFlags $DIR/config/mem-cpu.c -lm -o $DIR/config/tmux-performance

echo "install zsh"

ln -f $DIR/zshenv $HOME/.zshenv

echo "install bashrc"
ln -f $DIR/bashrc $HOME/.bashrc

echo "install vimrc"
ln -sf $DIR/vimrc $HOME/.vimrc

echo "install ssh"
mkdir -p $HOME/.ssh

chmod 700 ~/.ssh
ln -f $DIR/ssh/authorized_keys $HOME/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ln -f $DIR/ssh/config $HOME/.ssh/config
chmod 644 ~/.ssh/config


ln -f $DIR/ssh/rc $HOME/.ssh/rc
chmod 644 ~/.ssh/rc

echo "Copy existing .config"
FILE_PATH="$HOME/.config"
EXPECTED_TARGET="$DIR/config"
if [ ! -L "$FILE_PATH" ] || [ "$(readlink "$FILE_PATH")" != "$EXPECTED_TARGET" ]; then
    cp -RLn $HOME/.config/* $DIR/config
    #rm -r $HOME/.config > /dev/null 2>&1
    ln -sF $DIR/config $HOME/.config
fi

echo "installing environment variables"
source $HOME/.config/variables

if [ "${YED}" != "no" ]; then
    ./yed_install.sh $YED_CORE_COMMAND $YED_YPM_UPDATE
fi
