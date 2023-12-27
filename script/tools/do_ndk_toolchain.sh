#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

ARCH=$1
if echo "${NDK_ARCHS[@]}" | grep -w -q "${ARCH}"; then
    echo "当前 NDK 编译环境配置为 ARCH=${ARCH}"
else
    echo "必须指定目标架构(${NDK_ARCHS[*]})，ARCH=${ARCH}"
    exit 1
fi

NDK_API=
NDK_TARGET=

case ${ARCH} in
    "arm64" )
        NDK_API=21
        NDK_TARGET=aarch64-linux-android
    ;;
    "armv7a" )
        NDK_API=16
        NDK_TARGET=armv7a-linux-androideabi
    ;;
    "x86_64" )
        NDK_API=21
        NDK_TARGET=x86_64-linux-android
    ;;
    "x86" )
        NDK_API=16
        NDK_TARGET=i686-linux-android
    ;;
esac

export TOOLCHAIN=$FF_ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64
export TARGET=${NDK_TARGET}
export API=${NDK_API}

export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

echo TOOLCHAIN="${TOOLCHAIN}"
echo TARGET="${TARGET}"
echo API="${API}"
echo AR="${AR}"
echo CC="${CC}"
echo AS="${AS}"
echo CXX="${CXX}"
echo LD="${LD}"
echo RANLIB="${RANLIB}"
echo STRIP="${STRIP}"