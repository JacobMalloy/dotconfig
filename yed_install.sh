#!/usr/bin/env bash


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

YPM_UPDATE="no"
CORE_INSTALL="no"
PLUGINS_INSTALL="yes"

PLUGIN_OPTO="-O3"
YED_EXTRA_FLAGS=""

for var in "$@"
do
    case "$var" in
    "--ypm-update")
        YPM_UPDATE="yes"
    ;;
    "--core-install")
        CORE_INSTALL="yes"
    ;;
    "--no-plugins")
        PLUGINS_INSTALL="no"
    ;;
    "--debug")
        PLUGIN_OPTO="-O0 -g"
        YED_EXTRA_FLAGS="-c debug"
    ;;
    *)
    printf "options are:\n--debug\n--ypm-update\n--core-install\n--no-plugins\n"
    exit 1
    ;;
    esac
done

cd $DIR

eval HM=$(echo ~${USER})

if [ $CORE_INSTALL == "yes" ]; then
    ./yed/yed/install.sh -p ~/.local ${YED_EXTRA_FLAGS}
fi

# YED_INSTALLATION_PREFIX="${HM}/.local"
C_FLAGS="${PLUGIN_OPTO} -shared -fPIC -Wall $(yed --print-cflags)"
CPP_FLAGS="${PLUGIN_OPTO} -shared -fPIC -Wall $(yed --print-cppflags)"
CC=gcc
CPP=g++
LD_FLAGS="$(yed --print-ldflags)"

if [ $(uname) = "Darwin" ]; then
	if uname -a | grep "arm64" >/dev/null 2>&1; then	
		C_Flags+=" -arch arm64"
	fi
fi


YED_DIR=${DIR}/yed
YED_PLUGIN_DIR=${YED_DIR}/plugins
HOME_YED_DIR=$(yed --print-config-dir)

pids=()

if [ $PLUGINS_INSTALL == "yes" ]; then
    for f in $(find ${YED_PLUGIN_DIR} -name "*.c"); do
        echo "Compiling ${f/${YED_PLUUGIN_DIR}/.yed} and installing."
        PLUG_DIR=$(dirname ${f/${YED_PLUGIN_DIR}/${HOME_YED_DIR}})
        PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

        mkdir -p ${PLUG_DIR}
        ${CC} ${f} ${C_FLAGS} ${LD_FLAGS} -o ${PLUG_FULL_PATH} &
        pids+=($!)
    done

    for f in $(find ${YED_PLUGIN_DIR} -name "*.cpp"); do
        echo "Compiling ${f/${YED_PLUUGIN_DIR}/.yed} and installing."
        PLUG_DIR=$(dirname ${f/${YED_PLUGIN_DIR}/${HOME_YED_DIR}})
        PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".cpp").so

        mkdir -p ${PLUG_DIR}
        ${CPP} --std=c++17 ${f} ${CPP_FLAGS} ${LD_FLAGS} -o ${PLUG_FULL_PATH} &
        pids+=($!)
    done

    for p in ${pids[@]}; do
        wait $p || exit 1
    done
fi

echo "Moving yedrc."
ln -sf ${YED_DIR}/yedrc ${HOME_YED_DIR}
ln -sf ${YED_DIR}/ypm_list ${HOME_YED_DIR}
ln -sf ${YED_DIR}/templates ${HOME_YED_DIR}

if [ $YPM_UPDATE == "yes" ]; then
    ./yed/ypm_install.sh
fi

echo "Done."
