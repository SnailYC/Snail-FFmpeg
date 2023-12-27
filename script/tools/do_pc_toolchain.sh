#!/bin/bash

PWD_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit;pwd)
. ${PWD_PATH}/../../config/config.sh

# 编译需要的脚本文件
if [ ! `which gas-preprocessor.pl` ]
then
  echo "################ 安装 gas-preprocessor.pl ################"
  (sudo curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
    -o /usr/local/bin/gas-preprocessor.pl \
  && sudo chmod +x /usr/local/bin/gas-preprocessor.pl) \
  || exit 1
fi

#export CHOST=x86_64
#export HOST=x86_64-apple-darwin
#export BASE_PATH=/usr/bin
#export CC=$BASE_PATH/clang
#export CXX=$BASE_PATH/clang++
#export AR=$BASE_PATH/ar
#export RANLIB=$BASE_PATH/ranlib
#export STRIP=$BASE_PATH/strip

ARCH="x86_64"
APPLE_TARGET="x86_64-apple-darwin"
XCRUN_SDK=macosx

I_CFLAGS=
I_CFLAGS="${I_CFLAGS} -arch ${ARCH}"

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


echo HOST="${HOST}"
echo BASE_PATH="${BASE_PATH}"
echo CC="${CC}"
echo CXX="${CXX}"
echo AR="${AR}"
echo RANLIB="${RANLIB}"
echo STRIP="${STRIP}"





