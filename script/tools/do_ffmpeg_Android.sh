#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

FF_SOURCE="${FFMPEG_SOURCE}" # 源码目录
echo "FF_SOURCE=${FF_SOURCE}"
if [ ! -r ${FF_SOURCE} ]
then
    echo "找不到 FFmpeg 源码目录"
    exit 1
fi

FF_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib() {
  ARCH=$1

  FF_TEMP="${FFMPEG_TEMP}/Android/${ARCH}" # 该次编译过程中产生的文件的存放目录
  FF_PREFIX="${FFMPEG_PREBUILT}/Android/${ARCH}" # 该次编译后的结果存放目录

  FF_X264_INCLUDE=${X264_PREBUILT}/Android/${ARCH}/include
  FF_X264_LIB=${X264_PREBUILT}/Android/${ARCH}/lib

  FF_FDK_AAC_INCLUDE=${FDK_AAC_PREBUILT}/Android/${ARCH}/include
  FF_FDK_AAC_LIB=${FDK_AAC_PREBUILT}/Android/${ARCH}/lib

  FF_LAME_INCLUDE=${LAME_PREBUILT}/Android/${ARCH}/include
  FF_LAME_LIB=${LAME_PREBUILT}/Android/${ARCH}/lib

  FF_CFG_FLAGS=
  FF_EXTRA_CFLAGS=
  FF_EXTRA_LDFLAGS=

  case ${ARCH} in
      "arm64" )
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --arch=aarch64"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-neon"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-thumb"
      ;;
      "armv7a" )
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --arch=armv7a"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --cpu=cortex-a8"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-neon"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-thumb"

          FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
          FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,--fix-cortex-a8"
      ;;
      "x86_64" )
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --arch=x86_64"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-neon"
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-thumb"
      ;;
      "x86" )
          FF_CFG_FLAGS="${FF_CFG_FLAGS} --arch=x86 --cpu=i686"
          FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=atom -msse3 -ffast-math -mfpmath=sse"
      ;;
  esac

  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-yasm"
  if [[ "${ARCH}" = "x86" || "${ARCH}" = "x86_64" ]]; then
      FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-asm"
  else
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-asm"
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-inline-asm"
  fi

  # export CFLAGS="-fPIC"
  # export CFLAGS="-fPIE -fPIC"
  # export LDFLAGS="-pie"

  FF_CFLAGS="-O3 -Wall -pipe \
  -std=c99 \
  -ffast-math \
  -fstrict-aliasing -Werror=strict-aliasing \
  -Wno-psabi -Wa,--noexecstack \
  -DANDROID -DNDEBUG"
  FF_LDFLAGS=""

  export COMMON_FF_CFG_FLAGS=
  . ${ROOT_FOLDER}/config/module.sh

  FF_CFG_FLAGS="${FF_CFG_FLAGS} ${COMMON_FF_CFG_FLAGS}"

  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-static"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --disable-shared"
  # Standard options:
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --prefix=${FF_PREFIX}" # 输出目录

  # Advanced options:
#  FF_CFG_FLAGS="${FF_CFG_FLAGS} --cross-prefix=${TARGET}-"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-cross-compile"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --target-os=linux"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-pic"


  FF_X264_EXIST="N"
  FF_FDK_AAC_EXIST="N"
  FF_LAME_EXIST="N"
  if [[ -d ${FF_X264_INCLUDE} && -d ${FF_X264_LIB} ]]; then
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-libx264"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-encoder=libx264"
      FF_EXTRA_CFLAGS="${FF_EXTRA_CFLAGS} -I${FF_X264_INCLUDE}"
      FF_EXTRA_LDFLAGS="${FF_EXTRA_LDFLAGS} -L${FF_X264_LIB}"
      FF_X264_EXIST="Y"
  fi

  if [[ -d ${FF_FDK_AAC_INCLUDE} && -d ${FF_FDK_AAC_LIB} ]]; then
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-libfdk-aac"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-encoder=libfdk_aac"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-decoder=libfdk_aac"
      FF_EXTRA_CFLAGS="${FF_EXTRA_CFLAGS} -I${FF_FDK_AAC_INCLUDE}"
      FF_EXTRA_LDFLAGS="${FF_EXTRA_LDFLAGS} -L${FF_FDK_AAC_LIB} -lm"
      FF_FDK_AAC_EXIST="Y"
  fi

  if [[ -d ${FF_LAME_INCLUDE} && -d ${FF_LAME_LIB} ]]; then
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-libmp3lame"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-encoder=libmp3lame"
      FF_EXTRA_CFLAGS="${FF_EXTRA_CFLAGS} -I${FF_LAME_INCLUDE}"
      FF_EXTRA_LDFLAGS="${FF_EXTRA_LDFLAGS} -L${FF_LAME_LIB}"
      FF_LAME_EXIST="Y"
  fi

  echo "################ FFmpeg-Android-${ARCH} 开始编译 ################"
  echo "================================================"
  echo ""
  echo "FF_X264_EXIST=${FF_X264_EXIST}"
  echo "FF_FDK_AAC_EXIST=${FF_FDK_AAC_EXIST}"
  echo "FF_LAME_EXIST=${FF_LAME_EXIST}"
  echo ""
  echo "================================================"

  sudo rm -R ${FF_PREFIX}
  mkdir -p ${FF_PREFIX}
  # cd ${FF_SOURCE}
  # rm config.*
  sudo rm -R ${FF_TEMP}
  mkdir -p ${FF_TEMP}
  cd ${FF_TEMP} || exit 1

  FF_CFG_FLAGS="${FF_CFG_FLAGS} --cc=${CC}"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --cxx=${CXX}"

  ${FF_SOURCE}/configure ${FF_CFG_FLAGS} \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --extra-cflags="${FF_CFLAGS} ${FF_EXTRA_CFLAGS}" \
  --extra-ldflags="${FF_LDFLAGS} ${FF_EXTRA_LDFLAGS}" || exit 1
  make clean

  cp config.* ${FF_PREFIX}
  make ${FF_MAKE_FLAGS} install || exit 1
  mkdir -p ${FF_PREFIX}/include/libffmpeg
  cp -f config.h ${FF_PREFIX}/include/libffmpeg/config.h

  # echo "################ 合并成单个 libffmpeg.a (${ARCH}) ################"
  FF_O_DIR="${FFMPEG_TEMP}/Android/${ARCH}"
  X_O_DIR="${X264_TEMP}/Android/${ARCH}"
  FA_O_DIR="${FDK_AAC_TEMP}/Android/${ARCH}"
  L_O_DIR="${LAME_TEMP}/Android/${ARCH}"

  FF_O_LIST=$(find ${FF_O_DIR} -name "*.o")
  if [[ ${FF_X264_EXIST} == "Y" ]]; then
      FF_O_LIST="${FF_O_LIST} $(find ${X_O_DIR} -name "*.o")"
  fi
  if [[ ${FF_FDK_AAC_EXIST} == "Y" ]]; then
      FF_O_LIST="${FF_O_LIST} $(find ${FA_O_DIR} -name "*.o")"
  fi
  if [[ ${FF_LAME_EXIST} == "Y" ]]; then
      FF_O_LIST="${FF_O_LIST} $(find ${L_O_DIR} -name "*.o")"
  fi

  mkdir -p ${FF_PREFIX}/libffmpeg
  ${AR} cru ${FF_PREFIX}/libffmpeg/libffmpeg-unstrip.a ${FF_O_LIST} || exit 1
  cp -f ${FF_PREFIX}/libffmpeg/libffmpeg-unstrip.a ${FF_PREFIX}/libffmpeg/libffmpeg.a || exit 1
  ${STRIP} --strip-unneeded ${FF_PREFIX}/libffmpeg/libffmpeg.a || exit 1

#  FF_PREBUILT_LIB=${FF_PREFIX}/lib
#  cd ${FF_PREBUILT_LIB} || exit
#  for LIB in *.a
#  do
#     ${STRIP} --strip-unneeded ${LIB}
#  done

  echo "################ FFmpeg-Android-${ARCH} 编译完成 ################"
}

function build() {
  ARCH=$1
  . ${PWD_PATH}/do_ndk_toolchain.sh "${ARCH}"

  export CFLAGS="${CFLAGS} -fPIC"

  buildLib ${ARCH}

  export CFLAGS=

  . ${PWD_PATH}/do_ndk_toolchain_clean.sh
}

ARCH=$1
echo "ARCH=${ARCH}"

if [[ "${ARCH}" == "all" ]]; then
    for ITEM in "${NDK_ARCHS[@]}"
    do
      build ${ITEM}
    done
fi

build ${ARCH}