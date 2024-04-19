#!/bin/bash

HOST_PKG_CONFIG_PATH=$(command -v pkg-config)
if [ -z "${HOST_PKG_CONFIG_PATH}" ]; then
  echo -e "\n(*) pkg-config command not found\n"
  exit 1
fi

LIB_NAME="ffmpeg"

echo -e "----------------------------------------------------------------" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Building ${LIB_NAME} for ${HOST} with the following environment variables\n" 1>>"${BASEDIR}"/build.log 2>&1
env 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: System information\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: $(uname -a)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1

FFMPEG_LIBRARY_PATH="${LIB_INSTALL_BASE}/${LIB_NAME}"
echo -e "\nINFO: Using FFMPEG_LIBRARY_PATH: ${FFMPEG_LIBRARY_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET PATHS
set_toolchain_paths "${LIB_NAME}"
export PKG_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}:$(pkg-config --variable pc_path pkg-config)"

echo -e "\nINFO: Using PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1
cur_path=`pwd`
echo -e "\nINFO: pwd for ${cur_path}\n" 1>>"${BASEDIR}"/build.log 2>&1

# mkdir build 1>>"${BASEDIR}"/build.log 2>&1

# cd build

make distclean 1>>"${BASEDIR}"/build.log 2>&1
./configure \
  --enable-shared --disable-static --enable-pic \
  --disable-ffplay \
  --disable-amd3dnow \
  --disable-amd3dnowext \
  --disable-debug \
  --disable-avdevice \
  --disable-encoders --enable-encoder=aac,libx264,tiff,bmp,gif,jpeg2000,mjpeg,png,rawvideo,pcm* \
  --enable-libx264 --enable-gpl \
  --disable-libxcb --disable-libxcb-shm --disable-libxcb-shape --disable-libxcb-xfixes \
  --disable-libdrm --disable-vaapi --disable-v4l2-m2m \
  --enable-hardcoded-tables \
  --prefix=${FFMPEG_LIBRARY_PATH} \
  1>>"${BASEDIR}"/build.log 2>&1
  # --disable-autodetect \
  # --disable-safe-bitstream-reader \
  # --enable-lto=no

if [[ $? -ne 0 ]]; then
    echo -e "\nffmpeg: configure failed\nSee build.log for details\n"
    exit 1
fi
make -j 1>>"${BASEDIR}"/build.log 2>&1
if [[ $? -ne 0 ]]; then
    echo -e "\nffmpeg: make failed\nSee build.log for details\n"
    exit 1
fi
make install  1>>"${BASEDIR}"/build.log 2>&1
if [[ $? -ne 0 ]]; then
    echo -e "\nffmpeg: install failed\nSee build.log for details\n"
    exit 1
fi
# MANUALLY COPY PKG-CONFIG FILES
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavformat.pc "${INSTALL_PKG_CONFIG_DIR}/libavformat.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libswresample.pc "${INSTALL_PKG_CONFIG_DIR}/libswresample.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libswscale.pc "${INSTALL_PKG_CONFIG_DIR}/libswscale.pc" || return 1
# overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavdevice.pc "${INSTALL_PKG_CONFIG_DIR}/libavdevice.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavfilter.pc "${INSTALL_PKG_CONFIG_DIR}/libavfilter.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavcodec.pc "${INSTALL_PKG_CONFIG_DIR}/libavcodec.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavutil.pc "${INSTALL_PKG_CONFIG_DIR}/libavutil.pc" || return 1

# MANUALLY ADD REQUIRED HEADERS
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/arm 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/aarch64 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/x86 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/arm 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/config.h "${FFMPEG_LIBRARY_PATH}"/include/config.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/x86/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/x86/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/arm/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/arm/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/network.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/network.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/os_support.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/os_support.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/url.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/url.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/attributes_internal.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/attributes_internal.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/bprint.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/bprint.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/getenv_utf8.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/getenv_utf8.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/internal.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/internal.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/libm.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/libm.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/reverse.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/reverse.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/thread.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/thread.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/asm.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/asm.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/arm/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/arm/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/aarch64/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/aarch64/timer.h 1>>"${BASEDIR}"/build.log 2>&1
# overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/emms.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/emms.h 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo -e "cp hearder failed\n\nSee build.log for details\n"
  exit 1
fi
