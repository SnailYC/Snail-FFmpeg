#!/bin/bash

BUILD_PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. "${BUILD_PWD_PATH}"/../config/config.sh

chmod +x "${BUILD_PWD_PATH}"/tools/do_x264_Android.sh
chmod +x "${BUILD_PWD_PATH}"/tools/do_lame_Android.sh
chmod +x "${BUILD_PWD_PATH}"/tools/do_fdk_aac_Android.sh

# --------------------------------------------
# X264
COMPILE_X264_PREFIX="${X264_PREBUILT}/Android"
COMPILE_X264_TEMP="${X264_TEMP}/Android"

sudo rm -R "${COMPILE_X264_PREFIX}"
sudo rm -R "${COMPILE_X264_TEMP}"

mkdir -p "${COMPILE_X264_PREFIX}"
mkdir -p "${COMPILE_X264_TEMP}"

. "${BUILD_PWD_PATH}"/tools/do_x264_Android.sh all

# --------------------------------------------
# mp3lame
COMPILE_LAME_PREFIX="${LAME_PREBUILT}/Android"
COMPILE_LAME_TEMP="${LAME_TEMP}/Android"

sudo rm -R "${COMPILE_LAME_PREFIX}"
sudo rm -R "${COMPILE_LAME_TEMP}"

mkdir -p "${COMPILE_LAME_PREFIX}"
mkdir -p "${COMPILE_LAME_TEMP}"

. "${BUILD_PWD_PATH}"/tools/do_lame_Android.sh all

# --------------------------------------------
# FDK-AAC
COMPILE_FDK_AAC_PREFIX="${FDK_AAC_PREBUILT}/Android"
COMPILE_FDK_AAC_TEMP="${FDK_AAC_TEMP}/Android"

sudo rm -R "${COMPILE_FDK_AAC_PREFIX}"
sudo rm -R "${COMPILE_FDK_AAC_TEMP}"

mkdir -p "${COMPILE_FDK_AAC_PREFIX}"
mkdir -p "${COMPILE_FDK_AAC_TEMP}"

. "${BUILD_PWD_PATH}"/tools/do_fdk_aac_Android.sh all