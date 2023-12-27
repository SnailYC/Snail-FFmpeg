#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

FA_SOURCE="${FDK_AAC_SOURCE}" # 源码目录
if [ ! -r ${FA_SOURCE} ]
then
    echo "找不到 fdk-aac 源码目录: ${FA_SOURCE}"
    exit 1
fi

FA_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib() {
  ARCH=$1

  FA_TEMP="${FDK_AAC_TEMP}/Android/${ARCH}" # 该次编译过程中产生的文件的存放目录
  FA_PREFIX="${FDK_AAC_PREBUILT}/Android/${ARCH}" # 该次编译后的结果存放目录

  FA_CFG_FLAGS=

  FA_CFG_FLAGS="${FA_CFG_FLAGS} --host=${TARGET}"

  FA_CFG_FLAGS="${FA_CFG_FLAGS} --prefix=${FA_PREFIX}"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --enable-static"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --disable-shared"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --with-pic=yes"

  echo "################ fdk-aac-Android-${ARCH} 开始编译 ################"
  # echo "FA_CFG_FLAGS=${FA_CFG_FLAGS}"
  sudo rm -R ${FA_PREFIX}
  mkdir -p ${FA_PREFIX}
  # cd ${FA_SOURCE}

  sudo rm -R ${FA_TEMP}
  mkdir -p ${FA_TEMP}
  cd ${FA_TEMP} || exit 1

  ${FA_SOURCE}/configure ${FA_CFG_FLAGS} || exit 1

  make clean
  make ${FA_MAKE_FLAGS} install || exit 1
  echo "################ fdk-aac-Android-${ARCH} 编译完成 ################"
}

function build() {
  ARCH=$1
  . ${PWD_PATH}/do_ndk_toolchain.sh "${ARCH}"

#  export CFLAGS="${CFLAGS} -fPIC"

  buildLib ${ARCH}

#  export CFLAGS=

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
