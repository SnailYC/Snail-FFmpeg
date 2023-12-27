#### 编译环境：

- Mac OS
- xcode
- Android-ndk-22

#### 特征：

- fdk-aac
- mp3lame
- x264
- 只编译静态库
- Android:

  - CPU:armv7a、arm64v8a、x86_64

  - API：armv7a使用 Android 16，arm64v8a、x86_64 使用 Android 21
- iOS:
  - CPU:armv7、arm64、i386、x86_64
  - 编译后的不同 CPU 架构的静态库合并
- Mac:
  - CPU:x86_64
  - 用于桌面开发测试，直接利用本机环境编译(由于当前项目中使用的 P2P 库只支持 x86_64，所以在 M1 MacOS 上，也默认交叉编译出 x86_64)

#### 编译准备：

1. 将 FF_ANDROID_NDK 环境变量添加到 ~/.bash_profile 中

   > 如：export FF_ANDROID_NDK=/Users/snailyc/Library/Android/sdk/ndk/22.1.7171670
2. 在 config/config.sh 中设置编译过程中的目录以及编译库的版本名称，第三方库不指定版本名称则认为是不编译
3. 初始化(这一步主要是下载源码)：

```shell
cd script
chmod +x init.sh
./init.sh 
```

#### Android 平台编译：

```shell
# 编译第三方库（fdk-aac、mp3lame、x264），纯净 FFmpeg 可不执行该步骤
chmod +x compile_3rd_party_Android.sh
./compile_3rd_party_Android.sh

# 编译 FFmpeg(FFmpeg 会判断是否有编译完成的第三方库并决定是否链接进来)
chmod +x compile_ffmpeg_Android.sh
./compile_ffmpeg_Android.sh
```

#### iOS 平台编译：

```shell
# 编译第三方库（fdk-aac、mp3lame、x264），纯净 FFmpeg 可不执行该步骤
chmod +x compile_3rd_party_iOS.sh
./compile_3rd_party_iOS.sh

# 编译 FFmpeg(FFmpeg 会判断是否有编译完成的第三方库并决定是否链接进来)
chmod +x compile_ffmpeg_iOS.sh
./compile_ffmpeg_iOS.sh
```

#### Mac 平台编译：

```shell
# 编译第三方库（fdk-aac、mp3lame、x264），纯净 FFmpeg 可不执行该步骤
chmod +x compile_3rd_party_pc.sh
./compile_3rd_party_x86_64.sh

# 编译 FFmpeg(FFmpeg 会判断是否有编译完成的第三方库并决定是否链接进来)
chmod +x compile_ffmpeg_pc.sh
./compile_ffmpeg_pc.sh
```

> 最终产物存放在 build/prebuilt 目录下

#### 使用：

##### 	cmake：		

```cmake
add_subdirectory(ffmpeg)
set(MY_LIBS ${MY_LIBS} ${FFMPEG_LIBS})
```