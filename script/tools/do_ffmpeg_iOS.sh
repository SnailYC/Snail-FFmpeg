#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

FF_SOURCE="${FFMPEG_SOURCE}" # 源码目录

if [ ! -r ${FF_SOURCE} ]
then
    echo "找不到 FFmpeg 源码目录"
    exit 1
fi

FF_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib() {

  FF_ARCH=$1

  FF_TEMP="${FFMPEG_TEMP}/iOS/${FF_ARCH}" # 该次编译过程中产生的文件的存放目录
  FF_PREFIX="${FFMPEG_PREBUILT}/iOS/${FF_ARCH}" # 该次编译后的结果存放目录

  FF_X264_INCLUDE=${X264_PREBUILT}/iOS/${FF_ARCH}/include
  FF_X264_LIB=${X264_PREBUILT}/iOS/${FF_ARCH}/lib

  FF_FDK_AAC_INCLUDE=${FDK_AAC_PREBUILT}/iOS/${FF_ARCH}/include
  FF_FDK_AAC_LIB=${FDK_AAC_PREBUILT}/iOS/${FF_ARCH}/lib

  FF_LAME_INCLUDE=${LAME_PREBUILT}/iOS/${FF_ARCH}/include
  FF_LAME_LIB=${LAME_PREBUILT}/iOS/${FF_ARCH}/lib

  FF_CFG_FLAGS=

  export COMMON_FF_CFG_FLAGS=
  . ${ROOT_FOLDER}/config/module.sh

  FF_CFG_FLAGS="${FF_CFG_FLAGS} ${COMMON_FF_CFG_FLAGS}"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --arch=${FF_ARCH}"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --target-os=darwin"

  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-static"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --disable-shared"
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --prefix=${FF_PREFIX}" # 输出目录
  FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-pic"

  if [[ "${FF_ARCH}" = "i386" || "${FF_ARCH}" = "x86_64" ]]
  then
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --disable-asm"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --disable-mmx"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --assert-level=2"
  else
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-neon"
  fi

  FF_EXTRA_CFLAGS=
  FF_EXTRA_LDFLAGS=

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
      FF_EXTRA_LDFLAGS="${FF_EXTRA_LDFLAGS} -L${FF_FDK_AAC_LIB}"
      FF_FDK_AAC_EXIST="Y"
  fi

  if [[ -d ${FF_LAME_INCLUDE} && -d ${FF_LAME_LIB} ]]; then
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-libmp3lame"
      FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-encoder=libmp3lame"
      FF_EXTRA_CFLAGS="${FF_EXTRA_CFLAGS} -I${FF_LAME_INCLUDE}"
      FF_EXTRA_LDFLAGS="${FF_EXTRA_LDFLAGS} -L${FF_LAME_LIB}"
      FF_LAME_EXIST="Y"
  fi

  echo "################ FFmpeg-iOS-${FF_ARCH} 开始编译 ################"
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
  sudo rm -R ${FF_TEMP}
  mkdir -p ${FF_TEMP}
  cd ${FF_TEMP}

  ${FF_SOURCE}/configure ${FF_CFG_FLAGS} \
  --nm="${NM}" \
  --ar="${AR}" \
  --as="${AS}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --strip="${STRIP}" \
  --ranlib="${RANLIB}" \
  --extra-cflags="${FF_EXTRA_CFLAGS}" \
  --extra-ldflags="${FF_EXTRA_LDFLAGS}" || exit 1
  make clean

  cp config.* ${FF_PREFIX}
  make ${FF_MAKE_FLAGS} install || exit 1
  mkdir -p ${FF_PREFIX}/include/libffmpeg
  cp -f config.h $FF_PREFIX/include/libffmpeg/config.h

  # echo "################ 合并成单个 libffmpeg.a (${FF_ARCH}) ################"
  FF_O_DIR="${FFMPEG_TEMP}/iOS/${FF_ARCH}"
  X_O_DIR="${X264_TEMP}/iOS/${FF_ARCH}"
  FA_O_DIR="${FDK_AAC_TEMP}/iOS/${FF_ARCH}"
  L_O_DIR="${LAME_TEMP}/iOS/${FF_ARCH}"

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
  ar cru ${FF_PREFIX}/libffmpeg/libffmpeg-unstrip.a ${FF_O_LIST}
  strip -x -S ${FF_PREFIX}/libffmpeg/libffmpeg-unstrip.a -o ${FF_PREFIX}/libffmpeg/libffmpeg.a
  echo "################ FFmpeg-iOS-${FF_ARCH} 编译完成 ################"
}

function build() {
  ARCH=$1
  . ${PWD_PATH}/do_ios_toolchain.sh "${ARCH}"

  buildLib ${ARCH}

  . ${PWD_PATH}/do_ios_toolchain_clean.sh
}

ARCH=$1
echo "ARCH=${ARCH}"

if [[ "${ARCH}" == "all" ]]; then
    for ITEM in "${IOS_ARCHS[@]}"
    do
      build ${ITEM}
    done
fi

build ${ARCH}