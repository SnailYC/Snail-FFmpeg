#!/bin/bash

TEMP_ROOT_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit;pwd) # ffmpeg 模块根目录
export ROOT_FOLDER=${TEMP_ROOT_FOLDER}
export SOURCE_FOLDER="${ROOT_FOLDER}/build/source" # 源码缓存目录，该目录下的 ${FF_VERSION_NAME} 目录就是 FFmpeg 源码
export NDK_TOOLCHAIN_FOLDER="${ROOT_FOLDER}/build/toolchain/ndk" # 构造独立工具链的缓存目录
export TEMP_FOLDER="${ROOT_FOLDER}/build/temp"  # 存放编译期间的中间文件，如.o 文件
export PREFIX_FOLDER="${ROOT_FOLDER}/build/tempPrebuilt" 
export OUTPUT_FOLDER="${ROOT_FOLDER}/build/prebuilt"  # 编译产物输出目录

TEMP_IS_LINUX="y" # 不用更改它，用于标记编译环境是否为 Linux（下面通过命令行自动识别）
TEMP_MAKE_FLAG=-j3
UNAME_S=$(uname -s)
if [[ "$UNAME_S" = "Darwin" ]]; then
    TEMP_IS_LINUX=""
    TEMP_MAKE_FLAG=-j$(sysctl -n machdep.cpu.thread_count)
fi
export FF_LINUX=${TEMP_IS_LINUX}
export MY_MAKE_FLAG=${TEMP_MAKE_FLAG}

# http://www.ffmpeg.org/releases/
export FFMPEG_VERSION_NAME="ffmpeg-4.4.4"
export FFMPEG_SOURCE=${SOURCE_FOLDER}/${FFMPEG_VERSION_NAME}
export FFMPEG_TEMP=${TEMP_FOLDER}/${FFMPEG_VERSION_NAME}
export FFMPEG_PREBUILT=${PREFIX_FOLDER}/${FFMPEG_VERSION_NAME}-prebuilt

# http://download.videolan.org/pub/videolan/x264/snapshots/
# export X264_VERSION_NAME="last_stable_x264"
export X264_VERSION_NAME="x264-snapshot-20191217-2245"
export X264_SOURCE=${SOURCE_FOLDER}/${X264_VERSION_NAME}
export X264_TEMP=${TEMP_FOLDER}/${X264_VERSION_NAME}
export X264_PREBUILT=${PREFIX_FOLDER}/${X264_VERSION_NAME}-prebuilt

# https://sourceforge.net/projects/opencore-amr/files/fdk-aac/
export FDK_AAC_VERSION_NAME="fdk-aac-2.0.2"
export FDK_AAC_SOURCE=${SOURCE_FOLDER}/${FDK_AAC_VERSION_NAME}
export FDK_AAC_TEMP=${TEMP_FOLDER}/${FDK_AAC_VERSION_NAME}
export FDK_AAC_PREBUILT=${PREFIX_FOLDER}/${FDK_AAC_VERSION_NAME}-prebuilt

# https://sourceforge.net/projects/lame/files/lame/
export LAME_VERSION_FOLDER="3.100"
export LAME_VERSION_NAME="lame-3.100"
export LAME_SOURCE=${SOURCE_FOLDER}/${LAME_VERSION_NAME}
export LAME_TEMP=${TEMP_FOLDER}/${LAME_VERSION_NAME}
export LAME_PREBUILT=${PREFIX_FOLDER}/${LAME_VERSION_NAME}-prebuilt

export NDK_ARCHS=(arm64 armv7a x86_64 x86)
export IOS_ARCHS=(arm64 armv7 x86_64 i386)