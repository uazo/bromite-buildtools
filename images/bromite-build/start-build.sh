#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

WORKSPACE=/home/lg/working_dir

PATH=$WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

export GOMA_SERVER_HOST=127.0.0.1
export GOMA_SERVER_PORT=5050
export GOMA_USE_SSL=false
export GOMA_HTTP_AUTHORIZATION_FILE=$WORKSPACE/.debug_auth_file
export GOMA_HERMETIC=error
export GOMA_USE_LOCAL=false
export GOMA_FALLBACK=true
export GOMA_ARBITRARY_TOOLCHAIN_SUPPORT=true

$WORKSPACE/goma/goma_ctl.py ensure_stop
$WORKSPACE/goma/goma_ctl.py ensure_start

cd chromium/src

if [[ -z "${GOMAJOBS}" ]]; then
    GOMAJOBS=40
fi

echo -e ${RED} -------- pre-cache toolchain ${NC}
../../casupload --cas-server=http://$REMOTEEXEC_ADDR --instance=default_instance \
        third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include \
        third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/include \
        third_party/llvm-build/Release+Asserts/lib \
        third_party/llvm-build/Release+Asserts/bin \
        buildtools/third_party/libc++ \
	chrome/android/profiles/afdo.prof


echo -e ${RED} -------- start build ${NC}
autoninja -j $GOMAJOBS -C out/bromite chrome_public_apk

bash

