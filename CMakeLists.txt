set(FFMPEG_LIBS "")
set(FFMPEG_INCLUDE_PATH "")

set(FFMPEG_PREBUILT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/build/prebuilt)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Android")
    message("Android 平台 ffmpeg")
    set(FFMPEG_ANDROID_DIR ${FFMPEG_PREBUILT_DIR}/Android)
    set(FFMPEG_INCLUDE_PATH ${FFMPEG_ANDROID_DIR}/include)

    set(FFMPEG_LIB_DIR ${FFMPEG_ANDROID_DIR}/lib/armv7a)
    # Android FFmpeg
    if (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "armeabi-v7a")
        set(FFMPEG_LIB_DIR ${FFMPEG_ANDROID_DIR}/lib/armv7a)
    elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "arm64-v8a")
        set(FFMPEG_LIB_DIR ${FFMPEG_ANDROID_DIR}/lib/arm64)
    elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "x86")
        set(FFMPEG_LIB_DIR ${FFMPEG_ANDROID_DIR}/lib/x86)
    elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "x86_64")
        set(FFMPEG_LIB_DIR ${FFMPEG_ANDROID_DIR}/lib/x86_64)
    endif ()

    set(FFMPEG_LIBS ${FFMPEG_LIBS} -Wl,-Bsymbolic -lm -lz)
elseif (${APPLE})
    if (${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        message("Darwin 平台 ffmpeg")

        set(FFMPEG_MAC_DIR ${FFMPEG_PREBUILT_DIR}/pc)
        set(FFMPEG_INCLUDE_PATH ${FFMPEG_MAC_DIR}/include)
        set(FFMPEG_LIB_DIR ${FFMPEG_MAC_DIR}/lib)
    elseif (${CMAKE_SYSTEM_NAME} STREQUAL "iOS")
        message("iOS 平台 ffmpeg")
        set(FFMPEG_IOS_DIR ${FFMPEG_PREBUILT_DIR}/iOS)
        set(FFMPEG_INCLUDE_PATH ${FFMPEG_IOS_DIR}/include)
        message("CMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}")
        set(FFMPEG_LIB_DIR ${FFMPEG_IOS_DIR}/lib/${CMAKE_OSX_ARCHITECTURES})
    endif ()
    find_library(CoreFoundation-lib CoreFoundation)
    set(FFMPEG_LIBS ${FFMPEG_LIBS} ${CoreFoundation-lib})

    find_library(Security-lib Security)
    set(FFMPEG_LIBS ${FFMPEG_LIBS} ${Security-lib})
endif ()

file(COPY ${FFMPEG_LIB_DIR}/libffmpeg.a DESTINATION ${CMAKE_BINARY_DIR})

add_library(ffmpeg-lib STATIC IMPORTED GLOBAL)
set_target_properties(ffmpeg-lib PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/libffmpeg.a)
set(FFMPEG_LIBS ${FFMPEG_LIBS} ffmpeg-lib)
target_include_directories(ffmpeg-lib INTERFACE ${FFMPEG_INCLUDE_PATH})

set(FFMPEG_LIBS ${FFMPEG_LIBS} PARENT_SCOPE)