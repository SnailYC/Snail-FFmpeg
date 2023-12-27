#!/bin/bash

FF_BUILD_PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)
. ${FF_BUILD_PWD_PATH}/../config/config.sh

chmod +x ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_pc.sh

COMPILE="Y"

OUTPUT_FOLDER_MAC=${OUTPUT_FOLDER}/pc
rm -R ${OUTPUT_FOLDER_MAC}

if [[ "${COMPILE}" ]]; then
    
    COMPILE_FFMPEG_PREFIX="${FFMPEG_PREBUILT}/pc"
    COMPILE_FFMPEG_TEMP="${FFMPEG_TEMP}/pc"
    
    rm -R ${COMPILE_FFMPEG_PREFIX}
    rm -R ${COMPILE_FFMPEG_TEMP}
    
    mkdir -p ${COMPILE_FFMPEG_PREFIX}
    mkdir -p ${COMPILE_FFMPEG_TEMP}
    
    . ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_pc.sh
    
fi

# 导出
mkdir -p ${OUTPUT_FOLDER_MAC}
cp -rf ${FFMPEG_PREBUILT}/pc/x86_64/include ${OUTPUT_FOLDER_MAC}

# ffmpeg (libffmpeg.a)
FF_OUTPUT_LIB_FOLDER=${OUTPUT_FOLDER_MAC}/lib
mkdir -p ${FF_OUTPUT_LIB_FOLDER}

cd ${FFMPEG_PREBUILT}/pc/x86_64/libffmpeg

# # 拷贝整个目录下的 .a 文件
# for LIB in *.a
# do
#     cp -f ${LIB} ${FF_OUTPUT_LIB_FOLDER}
# done

# 只拷贝 libffmpeg.a 文件
cp -f libffmpeg.a ${FF_OUTPUT_LIB_FOLDER}
