#!/bin/bash

YED_CONFIG_DIRECTORY=$(yed --print-config-dir)

cd $YED_CONFIG_DIRECTORY

if ! [ -d ypm ]; then
    echo "Clone ypm_plugins"
    git clone https://github.com/your-editor/ypm-plugins ypm
fi

cd ypm

git reset --hard HEAD > /dev/null 2>&1
git fetch
git checkout v$(yed --major-version)
git pull

git submodule init

mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/syntax
mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/tools
mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/styles

for word in $(<../ypm_list); do
    if [ -d "./ypm_plugins/${word}" ]; then
        echo "Cloning building and installing ${word}"
        #git submodule update --remote ./ypm_plugins/${word} &
        bash -c "git submodule update --force ./ypm_plugins/${word} && cd ./ypm_plugins/${word} && ./build.sh && mv ./*.so ${YED_CONFIG_DIRECTORY}/ypm/plugins/${word}.so" &
    fi
done

wait

#cat ../ypm_list | xargs printf -- "ypm_plugins/%s " | xargs git submodule update --init --remote # I really liked this way of doing it, but it was single threaded and slow


# for word in $(<../ypm_list); do
#     if [ -d "./ypm_plugins/${word}" ]; then
#         echo "building ${word}"
#         cd ./ypm_plugins/${word}
#         ./build.sh &
#         cd ${YED_CONFIG_DIRECTORY}/ypm
#     fi
# done
#
# wait

#cd ${YED_CONFIG_DIRECTORY}/ypm/ypm_plugins

# mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/syntax
# mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/tools
# mkdir -p ${YED_CONFIG_DIRECTORY}/ypm/plugins/styles

#echo "copying binaries"
# find . -maxdepth 2 -name "*.so" -exec mv {} ${YED_CONFIG_DIRECTORY}/ypm/plugins \;
# find ./lang/ -maxdepth 2 -name "*.so" -exec mv {} ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang \;
# find ./lang/syntax/ -maxdepth 2 -name "*.so" -exec mv {} ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/syntax \;
# find ./lang/tools/ -maxdepth 2 -name "*.so" -exec mv {} ${YED_CONFIG_DIRECTORY}/ypm/plugins/lang/tools \;
# find ./styles/ -maxdepth 2 -name "*.so" -exec mv {} ${YED_CONFIG_DIRECTORY}/ypm/plugins/styles \;
