#!/bin/bash

BUILD_PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${BUILD_PWD_PATH}/../config/config.sh

chmod +x ${BUILD_PWD_PATH}/tools/do_x264_iOS.sh
chmod +x ${BUILD_PWD_PATH}/tools/do_lame_iOS.sh
chmod +x ${BUILD_PWD_PATH}/tools/do_fdk_aac_iOS.sh

# --------------------------------------------
# X264
COMPILE_X264_PREFIX="${X264_PREBUILT}/iOS"
COMPILE_X264_TEMP="${X264_TEMP}/iOS"
 
sudo rm -R ${COMPILE_X264_PREFIX}
sudo rm -R ${COMPILE_X264_TEMP}

mkdir -p ${COMPILE_X264_PREFIX}
mkdir -p ${COMPILE_X264_TEMP}
. ${BUILD_PWD_PATH}/tools/do_x264_iOS.sh all

# --------------------------------------------
# mp3lame
COMPILE_LAME_PREFIX="${LAME_PREBUILT}/iOS"
COMPILE_LAME_TEMP="${LAME_TEMP}/iOS"
 
sudo rm -R ${COMPILE_LAME_PREFIX}
sudo rm -R ${COMPILE_LAME_TEMP}

mkdir -p ${COMPILE_LAME_PREFIX}
mkdir -p ${COMPILE_LAME_TEMP}
. ${BUILD_PWD_PATH}/tools/do_lame_iOS.sh all

# --------------------------------------------
# FDK-AAC
COMPILE_FDK_AAC_PREFIX="${FDK_AAC_PREBUILT}/iOS"
COMPILE_FDK_AAC_TEMP="${FDK_AAC_TEMP}/iOS"
 
sudo rm -R ${COMPILE_FDK_AAC_PREFIX}
sudo rm -R ${COMPILE_FDK_AAC_TEMP}

mkdir -p ${COMPILE_FDK_AAC_PREFIX}
mkdir -p ${COMPILE_FDK_AAC_TEMP}
. ${BUILD_PWD_PATH}/tools/do_fdk_aac_iOS.sh all













