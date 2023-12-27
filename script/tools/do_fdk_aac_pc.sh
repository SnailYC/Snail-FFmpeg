#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

FA_SOURCE="${FDK_AAC_SOURCE}" # 源码目录

if [ ! -r ${FA_SOURCE} ]
then
    echo "找不到 fdk-aac 源码目录"
    exit 1
fi

FA_MAKE_FLAGS=${MY_MAKE_FLAG}

function buildLib() {
  FA_TEMP="${FDK_AAC_TEMP}/pc/${ARCH}" # 该次编译过程中产生的文件的存放目录
  FA_PREFIX="${FDK_AAC_PREBUILT}/pc/${ARCH}" # 该次编译后的结果存放目录

  FA_CFG_FLAGS=
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --prefix=$FA_PREFIX" # 输出目录
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --enable-static"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --disable-shared"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --with-pic=yes"
  FA_CFG_FLAGS="${FA_CFG_FLAGS} --host=${TARGET}"

  echo "################ fdk-aac-PC 开始编译 ################"
  echo "FA_SOURCE=${FA_SOURCE}"
  sudo rm -R ${FA_PREFIX}
  mkdir -p ${FA_PREFIX}

  # cd ${FA_SOURCE}

  sudo rm -R ${FA_TEMP}
  mkdir -p ${FA_TEMP}
  cd ${FA_TEMP}

  ${FA_SOURCE}/configure ${FA_CFG_FLAGS} || exit 1

  make clean
  make ${FA_MAKE_FLAGS} install || exit 1

  echo "################ fdk-aac-PC 编译完成 ################"
}

function build() {
  . ${PWD_PATH}/do_pc_toolchain.sh

  buildLib ${ARCH}

  . ${PWD_PATH}/do_pc_toolchain_clean.sh
}

build