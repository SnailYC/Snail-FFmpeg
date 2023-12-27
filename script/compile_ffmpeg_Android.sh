#!/bin/bash

FF_BUILD_PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)
. ${FF_BUILD_PWD_PATH}/../config/config.sh

chmod +x ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_Android.sh

# 是否重新编译 ffmpeg，非 Y 则只从 tempPrebuilt 目录中导出 ffmpeg
COMPILE="Y"

OUTPUT_FOLDER_ANDROID=${OUTPUT_FOLDER}/Android
rm -R ${OUTPUT_FOLDER_ANDROID}
if [[ "${COMPILE}" == "Y" ]]; then
    COMPILE_FFMPEG_PREFIX="${FFMPEG_PREBUILT}/Android"
    COMPILE_FFMPEG_TEMP="${FFMPEG_TEMP}/Android"
    
    rm -R ${COMPILE_FFMPEG_PREFIX}
    rm -R ${COMPILE_FFMPEG_TEMP}
    
    mkdir -p ${COMPILE_FFMPEG_PREFIX}
    mkdir -p ${COMPILE_FFMPEG_TEMP}
    
    . ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_Android.sh all
fi

# include
mkdir -p ${OUTPUT_FOLDER_ANDROID}
cp -rf ${FFMPEG_PREBUILT}/Android/${NDK_ARCHS[0]}/include ${OUTPUT_FOLDER_ANDROID}

for ARCH in "${NDK_ARCHS[@]}"; do
    # ffmpeg
    FF_OUTPUT_LIB_FOLDER=${OUTPUT_FOLDER_ANDROID}/lib/${ARCH}
    mkdir -p ${FF_OUTPUT_LIB_FOLDER}

    FF_PREBUILT_LIB_FFMPEG_ANDROID=${FFMPEG_PREBUILT}/Android/${ARCH}/libffmpeg
    cd ${FF_PREBUILT_LIB_FFMPEG_ANDROID}
    
    # # 拷贝整个目录下的 .a 文件
    # for LIB in *.a
    # do
    #     cp -f ${LIB} ${FF_OUTPUT_LIB_FOLDER}
    # done
    
    # 只拷贝 libffmpeg.a 文件
    cp -f libffmpeg.a ${FF_OUTPUT_LIB_FOLDER}
done

