#! /usr/bin/env bash

./yed/yed/install.sh -p ~/.local

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~${USER})

rm -rf ~/.yed 2>/dev/null
mkdir -p ~/.yed

# YED_INSTALLATION_PREFIX="${HM}/.local"
C_FLAGS="-O2 -march=native -mtune=native -shared -fPIC -Wall -Werror $(yed --print-cflags)"
CC=gcc
LD_FLAGS="$(yed --print-ldflags)"


YED_DIR=${DIR}/yed
YED_PLUGIN_DIR=${YED_DIR}/plugins
HOME_YED_DIR=${HM}/.yed

pids=()

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

echo "Moving yedrc."
ln -sf ${YED_DIR}/yedrc ${HOME_YED_DIR}
ln -sf ${YED_DIR}/ypm_list ${HOME_YED_DIR}
ln -sf ${YED_DIR}/templates ${HOME_YED_DIR}
echo "Done."
