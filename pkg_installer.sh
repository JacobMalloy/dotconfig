#!/usr/bin/env bash


if [ $(uname) = "Darwin" ]; then
    BREW_CMD=$(which brew 2>/dev/null)
else
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
YUM_CMD=$(which yum 2>/dev/null)
APT_CMD=$(which apt 2>/dev/null)
PACMAN_CMD=$(which pacman 2>/dev/null)
fi

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


PREFIX=""

if [[ ! -z $APT_CMD ]]; then
    PREFIX="${DIR}/pkgs/apt/"
elif [[ ! -z $BREW_CMD ]]; then
    PREFIX="${DIR}/pkgs/brew/"
elif [[ ! -z $PACMAN_CMD ]]; then
    PREFIX="${DIR}/pkgs/pacman/"
else
    echo "error package manager not supported"
    exit 1;
fi


while getopts 'a' flag; do
    case "${flag}" in
        a) RETURN_VALUES="$(sort -u $(ls -d ${PREFIX}* | xargs) | xargs)" ;;
    esac
done
if [ -z ${RETURN_VALUES+x} ]; then
    for VALUE in "$@"
    do
        if [ -f "${PREFIX}${VALUE}" ]; then
            FILES+="${PREFIX}${VALUE} "
        fi
    done
    if [ -z ${FILES+x} ]; then
        echo "please give valid files or -a"
        exit 1
    fi
    RETURN_VALUES="$(sort -u ${FILES} | xargs)"
fi


if [[ ! -z $APT_CMD ]]; then
    apt install -y ${RETURN_VALUES}
elif [[ ! -z $BREW_CMD ]]; then
    brew install ${RETURN_VALUES}
elif [[ ! -z $PACMAN_CMD ]]; then
    pacman -Sy --needed $RETURN_VALUES
else
    echo "error package manager not supported"
    exit 1;
fi
