#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

ARCH=$1
#export IOS_ARCHS=(arm64 armv7 x86_64 i386)
if echo "${IOS_ARCHS[@]}" | grep -w -q "${ARCH}"; then
  echo "当前 iOS 编译环境配置为 ARCH=${ARCH}"
else
  echo "必须指定目标架构(${IOS_ARCHS[*]})，ARCH=${ARCH}"
  exit 1
fi

# 编译需要的脚本文件
if [ ! `which gas-preprocessor.pl` ]
then
  echo "################ 安装 gas-preprocessor.pl ################"
  (sudo curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
    -o /usr/local/bin/gas-preprocessor.pl \
  && sudo chmod +x /usr/local/bin/gas-preprocessor.pl) \
  || exit 1
fi

XCRUN_PLATFORM=
APPLE_TARGET=
PREPROCESSOR_ARCH=

I_CFLAGS=
I_CFLAGS="${I_CFLAGS} -arch ${ARCH}"
case ${ARCH} in
  "arm64" )
    XCRUN_PLATFORM="iPhoneOS"
    APPLE_TARGET="aarch64-apple-darwin"
    I_CFLAGS="${I_CFLAGS} -miphoneos-version-min=8.0"
    PREPROCESSOR_ARCH="-arch aarch64"
  ;;
  "armv7" )
    XCRUN_PLATFORM="iPhoneOS"
    APPLE_TARGET="arm-apple-darwin"
    I_CFLAGS="${I_CFLAGS} -miphoneos-version-min=8.0"
    PREPROCESSOR_ARCH="-arch arm"
  ;;
  "x86_64" )
    XCRUN_PLATFORM="iPhoneSimulator"
    APPLE_TARGET="x86_64-apple-darwin"
    I_CFLAGS="${I_CFLAGS} -mios-simulator-version-min=8.0"
  ;;
  "i386" )
    XCRUN_PLATFORM="iPhoneSimulator"
    APPLE_TARGET="i386-apple-darwin"
    I_CFLAGS="${I_CFLAGS} -march=i386 -mtune=i386"
    I_CFLAGS="${I_CFLAGS} -mios-simulator-version-min=8.0"
  ;;
esac

XCRUN_SDK=$(echo ${XCRUN_PLATFORM} | tr '[:upper:]' '[:lower:]')
LD=$(xcrun -sdk "${XCRUN_SDK}" -f ld)

export TARGET=${APPLE_TARGET}
export AR="xcrun -sdk ${XCRUN_SDK} ar"
export CC="xcrun -sdk ${XCRUN_SDK} clang -arch ${ARCH}"
#export CC="xcrun -sdk ${XCRUN_SDK} clang -arch ${ARCH} -fembed-bitcode"
export AS="gas-preprocessor.pl ${PREPROCESSOR_ARCH} -- $CC"
#export AS="gas-preprocessor.pl -- xcrun -sdk ${XCRUN_SDK} as -arch ${ARCH}"
export CXX="xcrun -sdk ${XCRUN_SDK} clang++ -arch ${ARCH}"
export LD=$LD
export RANLIB="xcrun -sdk ${XCRUN_SDK} ranlib"
export STRIP="xcrun -sdk ${XCRUN_SDK} strip"
export CFLAGS=${I_CFLAGS}
export CXXFLAGS=${I_CFLAGS}

echo AR="${AR}"
echo CC="${CC}"
echo AS="${AS}"
echo CXX="${CXX}"
echo LD="${LD}"
echo RANLIB="${RANLIB}"
echo STRIP="${STRIP}"

echo CFLAGS="${STRIP}"
echo CXXFLAGS="${STRIP}"


