#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)
. ${PWD_PATH}/../config/config.sh

if [[ ${FF_LINUX} == "" ]]; then
    if [ ! `which yasm` ]
    then
        echo 'Yasm not found'
        if [ ! `which brew` ]
        then
            echo 'Homebrew not found. Trying to install...'
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
            || exit 1
        fi
        echo 'Trying to install Yasm...'
        brew install yasm || exit 1
    fi
fi

if [[ "${FFMPEG_VERSION_NAME}" ]]; then
    # 下载 FFmpeg
    if [ ! -r ${FFMPEG_SOURCE} ]
    then
        echo "下载 ${FFMPEG_VERSION_NAME} 到 ${FFMPEG_SOURCE}"
        mkdir -p ${FFMPEG_SOURCE}
        curl -# http://www.ffmpeg.org/releases/${FFMPEG_VERSION_NAME}.tar.bz2 | tar xj \
        -C ${FFMPEG_SOURCE} --strip-components 1 \
        || exit 1
    fi
fi

if [[ "${FDK_AAC_VERSION_NAME}" ]]; then
    # 下载 fdk-aac
    if [ ! -r ${FDK_AAC_SOURCE} ]
    then
        echo "下载 ${FDK_AAC_VERSION_NAME} 到 ${FDK_AAC_SOURCE}"
        mkdir -p ${FDK_AAC_SOURCE}
        curl -# https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/${FDK_AAC_VERSION_NAME}.tar.gz | tar -xz \
        -C ${FDK_AAC_SOURCE} --strip-components 1 \
        || exit 1

        # 当前使用版本为 fdk-aac-2.0.2，该版本的 lpp_tran.cpp 中，使用了 Android 的 log 库，但其引用有问题，导致编译失败
        # 以下代码作用为，删除该文件中所有被 #ifdef __ANDROID__ ... #endif 包裹的代码（原代码中使用的都是 log 相关，不影响库的使用）
        FILE_lpp_tran=${FDK_AAC_SOURCE}/libSBRdec/src/lpp_tran.cpp
        sed '/#ifdef __ANDROID__/,/#endif/d' "${FILE_lpp_tran}" > "${FILE_lpp_tran}"
    fi
fi

if [[ "${LAME_VERSION_FOLDER}" && "${LAME_VERSION_NAME}" ]]; then
    # 下载 lame
    if [ ! -r ${LAME_SOURCE} ]
    then
        echo "下载 ${LAME_VERSION_NAME} 到 ${LAME_SOURCE}"
        mkdir -p ${LAME_SOURCE}
        curl -# https://nchc.dl.sourceforge.net/project/lame/lame/${LAME_VERSION_FOLDER}/${LAME_VERSION_NAME}.tar.gz | tar -xz \
        -C ${LAME_SOURCE} --strip-components 1 \
        || exit 1
    fi
fi

if [[ "${X264_VERSION_NAME}" ]]; then
    # 下载 X264
    if [ ! -r ${X264_SOURCE} ]
    then
        echo "下载 ${X264_VERSION_NAME} 到 ${X264_SOURCE}"
        mkdir -p ${X264_SOURCE}
        curl -# http://download.videolan.org/pub/videolan/x264/snapshots/${X264_VERSION_NAME}.tar.bz2 | tar xj \
        -C ${X264_SOURCE} --strip-components 1 \
        || exit 1
    fi
fi

echo "FFMPEG_SOURCE=${FFMPEG_SOURCE}"
echo "FDK_AAC_SOURCE=${FDK_AAC_SOURCE}"
echo "X264_SOURCE=${X264_SOURCE}"
echo "LAME_SOURCE=${LAME_SOURCE}"





