#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

X_SOURCE="${X264_SOURCE}" # 源码目录

if [ ! -r ${X_SOURCE} ]
then
    echo "找不到 X264 源码目录"
    exit 1
fi

X_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib(){
  ARCH=$1

  X_TEMP="${X264_TEMP}/Android/${ARCH}" # 该次编译过程中产生的文件的存放目录
  X_PREFIX="${X264_PREBUILT}/Android/${ARCH}" # 该次编译后的结果存放目录

  X_CFG_FLAGS=

  X_CFG_FLAGS="${X_CFG_FLAGS} --host=${TARGET}"
  case ${ARCH} in
      "arm64" )
          # FF_CFG_FLAGS="${FF_CFG_FLAGS} --enable-yasm"
      ;;
      "armv7a" )
          # FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
          # FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,--fix-cortex-a8"
      ;;
      "x86_64" )
          X_CFG_FLAGS="${X_CFG_FLAGS} --arch=x86_64"
          X_CFG_FLAGS="${X_CFG_FLAGS} --disable-asm"
      ;;
      "x86" )
          X_CFG_FLAGS="${X_CFG_FLAGS} --disable-asm"

          # FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=atom -msse3 -ffast-math -mfpmath=sse"
      ;;
  esac

  X_CFG_FLAGS="${X_CFG_FLAGS} --prefix=${X_PREFIX}"
  X_CFG_FLAGS="${X_CFG_FLAGS} --enable-static"
  X_CFG_FLAGS="${X_CFG_FLAGS} --enable-pic"
  X_CFG_FLAGS="${X_CFG_FLAGS} --disable-cli"
  X_CFG_FLAGS="${X_CFG_FLAGS} --enable-strip"

  echo "################ X264-Android-${ARCH} 开始编译 ################"
  # echo "X_CFG_FLAGS=${X_CFG_FLAGS}"
  sudo rm -R ${X_PREFIX}
  mkdir -p ${X_PREFIX}
  # cd ${X_SOURCE}
  # rm config.*
  sudo rm -R ${X_TEMP}
  mkdir -p ${X_TEMP}
  cd ${X_TEMP} || exit

  # shellcheck disable=SC2086
  CC=$CC ${X_SOURCE}/configure ${X_CFG_FLAGS}

  make clean
  # shellcheck disable=SC2086
  make ${X_MAKE_FLAGS} install || exit 1

  # X_PREBUILT_LIB=${X_PREFIX}/lib
  # cd ${X_PREBUILT_LIB} || exit
  # for LIB in *.a
  # do
  #     ${STRIP} --strip-unneeded ${LIB}
  # done

  echo "################ X264-Android-${ARCH} 编译完成 ################"
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