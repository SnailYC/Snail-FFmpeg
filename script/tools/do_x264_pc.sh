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

function buildLib() {
  X_TEMP="${X264_TEMP}/pc/${ARCH}" # 该次编译过程中产生的文件的存放目录
  X_PREFIX="${X264_PREBUILT}/pc/${ARCH}" # 该次编译后的结果存放目录

  X_CFG_FLAGS=
  X_CFG_FLAGS="${X_CFG_FLAGS} --prefix=$X_PREFIX" # 输出目录
  X_CFG_FLAGS="${X_CFG_FLAGS} --enable-static"
  X_CFG_FLAGS="${X_CFG_FLAGS} --enable-pic"
  X_CFG_FLAGS="${X_CFG_FLAGS} --disable-cli"
  X_CFG_FLAGS="${X_CFG_FLAGS} --disable-asm"
  X_CFG_FLAGS="${X_CFG_FLAGS} --host=${TARGET}"


  echo "################ X264-PC 开始编译 ################"
  echo "X_SOURCE=${X_SOURCE}"
  sudo rm -R ${X_PREFIX}
  mkdir -p ${X_PREFIX}
  # cd ${X_SOURCE}
  sudo rm -R ${X_TEMP}
  mkdir -p ${X_TEMP}
  cd ${X_TEMP}

  ${X_SOURCE}/configure ${X_CFG_FLAGS} || exit 1

  make clean
  make ${X_MAKE_FLAGS} install || exit 1

  echo "################ X264-PC 编译完成 ################"
}

function build() {
  . ${PWD_PATH}/do_pc_toolchain.sh

  buildLib ${ARCH}

  . ${PWD_PATH}/do_pc_toolchain_clean.sh
}

build