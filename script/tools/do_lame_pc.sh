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
  L_TEMP="${LAME_TEMP}/pc/${ARCH}" # 该次编译过程中产生的文件的存放目录
  L_PREFIX="${LAME_PREBUILT}/pc/${ARCH}" # 该次编译后的结果存放目录

  L_CFG_FLAGS=
  L_CFG_FLAGS="${L_CFG_FLAGS} --prefix=$L_PREFIX" # 输出目录
  L_CFG_FLAGS="${L_CFG_FLAGS} --enable-static"
  L_CFG_FLAGS="${L_CFG_FLAGS} --disable-shared"
  L_CFG_FLAGS="${L_CFG_FLAGS} --disable-frontend"
  L_CFG_FLAGS="${L_CFG_FLAGS} --host=${TARGET}"

  echo "################ mp3lame-PC 开始编译 ################"
  echo "L_SOURCE=${L_SOURCE}"
  sudo rm -R ${L_PREFIX}
  mkdir -p ${L_PREFIX}
  # cd ${L_SOURCE}

  sudo rm -R ${L_TEMP}
  mkdir -p ${L_TEMP}
  cd ${L_TEMP}

  ${L_SOURCE}/configure ${L_CFG_FLAGS} || exit 1

  make clean
  make ${L_MAKE_FLAGS} install || exit 1

  echo "################ mp3lame-PC 编译完成 ################"
}

function build() {
  . ${PWD_PATH}/do_pc_toolchain.sh

  buildLib ${ARCH}

  . ${PWD_PATH}/do_pc_toolchain_clean.sh
}

build