#! /usr/bin/env bash


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

YPM_UPDATE="no"
CORE_INSTALL="no"
PLUGINS_INSTALL="yes"

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
    *)
    printf "options are:\n--ypm-update\n--core-install\n--no-plugins\n"
    exit 1
    ;;
    esac
done

cd $DIR

eval HM=$(echo ~${USER})

if [ $CORE_INSTALL == "yes" ]; then
    ./yed/yed/install.sh -p ~/.local
fi

# YED_INSTALLATION_PREFIX="${HM}/.local"
C_FLAGS="-O2 -shared -fPIC -Wall $(yed --print-cflags)"
CC=gcc
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

    for p in ${pids[@]}; do
        wait $p || exit 1
    done
fi

echo "Moving yedrc."
ln -f ${YED_DIR}/yedrc ${HOME_YED_DIR}
ln -f ${YED_DIR}/ypm_list ${HOME_YED_DIR}
ln -sf ${YED_DIR}/templates ${HOME_YED_DIR}

if [ $YPM_UPDATE == "yes" ]; then
    yed -c jacobmalloy-ypm-update-quit
fi

echo "Done."
