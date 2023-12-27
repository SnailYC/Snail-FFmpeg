#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

L_SOURCE="${LAME_SOURCE}" # 源码目录
if [ ! -r ${L_SOURCE} ]
then
    echo "找不到 mp3lame 源码目录"
    exit 1
fi

L_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib() {
  L_ARCH=$1

  L_TEMP="${LAME_TEMP}/iOS/${L_ARCH}" # 该次编译过程中产生的文件的存放目录
  L_PREFIX="${LAME_PREBUILT}/iOS/${L_ARCH}" # 该次编译后的结果存放目录

  L_CFG_FLAGS=

  L_CFG_FLAGS="${L_CFG_FLAGS} --host=${TARGET}"

  L_CFG_FLAGS="${L_CFG_FLAGS} --prefix=$L_PREFIX" # 输出目录
  L_CFG_FLAGS="${L_CFG_FLAGS} --enable-static"
  L_CFG_FLAGS="${L_CFG_FLAGS} --disable-shared"
  L_CFG_FLAGS="${L_CFG_FLAGS} --disable-frontend"

  echo "################ mp3lame-iOS-${L_ARCH} 开始编译 ################"
  echo "L_SOURCE=${L_SOURCE}"
  sudo rm -R ${L_PREFIX}
  mkdir -p ${L_PREFIX}
  # cd ${L_SOURCE}

  sudo rm -R ${L_TEMP}
  mkdir -p ${L_TEMP}
  cd ${L_TEMP}

  CC=$CC ${L_SOURCE}/configure ${L_CFG_FLAGS} || exit 1

  make clean
  make ${L_MAKE_FLAGS} install || exit 1

  echo "################ mp3lame-iOS-${L_ARCH} 编译完成 ################"
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
