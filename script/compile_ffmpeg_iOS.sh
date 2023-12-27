#!/bin/bash

FF_BUILD_PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${FF_BUILD_PWD_PATH}/../config/config.sh

chmod +x ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_iOS.sh

COMPILE="Y"

OUTPUT_FOLDER_IOS=${OUTPUT_FOLDER}/iOS
rm -R ${OUTPUT_FOLDER_IOS}

if [[ "${COMPILE}" == "Y" ]]; then
  COMPILE_FFMPEG_PREFIX="${FFMPEG_PREBUILT}/iOS"
  COMPILE_FFMPEG_TEMP="${FFMPEG_TEMP}/iOS"

  rm -R ${COMPILE_FFMPEG_PREFIX}
  rm -R ${COMPILE_FFMPEG_TEMP}

  mkdir -p ${COMPILE_FFMPEG_PREFIX}
  mkdir -p ${COMPILE_FFMPEG_TEMP}

  . ${FF_BUILD_PWD_PATH}/tools/do_ffmpeg_iOS.sh all
fi
# 导出
# include
mkdir -p ${OUTPUT_FOLDER_IOS}
cp -rf ${FFMPEG_PREBUILT}/iOS/${IOS_ARCHS[0]}/include ${OUTPUT_FOLDER_IOS}

B_LIB_I386=""
B_LIB_X86_64=""
B_LIB_ARMV7=""
B_LIB_ARM64=""
for ARCH in "${IOS_ARCHS[@]}"; do
  B_BUILD_DIR="${OUTPUT_FOLDER_IOS}/lib/${ARCH}"
  mkdir -p "$B_BUILD_DIR" || exit 1
  cp "${FFMPEG_PREBUILT}/iOS/${ARCH}/libffmpeg/libffmpeg.a" "$B_BUILD_DIR" || exit 1
  case ${ARCH} in
    "i386" )
      B_LIB_I386="${B_BUILD_DIR}/libffmpeg.a"
    ;;
    "x86_64" )
      B_LIB_X86_64="${B_BUILD_DIR}/libffmpeg.a"
    ;;
    "armv7" )
      B_LIB_ARMV7="${B_BUILD_DIR}/libffmpeg.a"
    ;;
    "arm64" )
      B_LIB_ARM64="${B_BUILD_DIR}/libffmpeg.a"
    ;;
  esac
done

B_BUILD_DIR="${OUTPUT_FOLDER_IOS}/lib/iPhoneOS" 
mkdir -p "$B_BUILD_DIR" || exit 1
if [ -n "$B_LIB_ARMV7" ] || [ -n "$B_LIB_ARM64" ];
then
    lipo -create ${B_LIB_ARMV7} ${B_LIB_ARM64} -output "${B_BUILD_DIR}/libffmpeg.a"
fi

B_BUILD_DIR="${OUTPUT_FOLDER_IOS}/lib/iPhoneSimulator"
mkdir -p "$B_BUILD_DIR" || exit 1
if [ -n "$B_LIB_I386" ] || [ -n "$B_LIB_X86_64" ];
then
    lipo -create ${B_LIB_I386} ${B_LIB_X86_64} -output "${B_BUILD_DIR}/libffmpeg.a"
fi

B_BUILD_DIR="${OUTPUT_FOLDER_IOS}/lib/iPhoneAll"
mkdir -p "$B_BUILD_DIR" || exit 1
if [ -n "$B_LIB_ARMV7" ] || [ -n "$B_LIB_ARM64" ] || [ -n "$B_LIB_I386" ] || [ -n "$B_LIB_X86_64" ];
then
    lipo -create ${B_LIB_ARMV7} ${B_LIB_ARM64} ${B_LIB_I386} ${B_LIB_X86_64} -output "${B_BUILD_DIR}/libffmpeg.a"
fi
