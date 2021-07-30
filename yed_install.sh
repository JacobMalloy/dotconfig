#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~${USER})


mkdir -p ~/.yed

# YED_INSTALLATION_PREFIX="${HM}/.local"
C_FLAGS="-O3 -shared -fPIC -Wall -Werror"
CC=gcc

C_FLAGS+=" -I$(yed --print-include-dir) -L$(yed --print-lib-dir) -lyed"


YED_DIR=${DIR}/yed
HOME_YED_DIR=${HM}/.yed

pids=()

for f in $(find ${DIR}/yed -name "*.c"); do
    echo "Compiling ${f/${YED_DIR}/.yed} and installing."
    PLUG_DIR=$(dirname ${f/${YED_DIR}/${HOME_YED_DIR}})
    PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

    mkdir -p ${PLUG_DIR}
    ${CC} ${f} ${C_FLAGS} -o ${PLUG_FULL_PATH} &
    pids+=($!)
done

for p in ${pids[@]}; do
    wait $p || exit 1
done

echo "Moving yedrc."
ln -sf ${YED_DIR}/yedrc ${HOME_YED_DIR}
ln -sf ${YED_DIR}/templates ${HOME_YED_DIR}
echo "Done."
