#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

WORKSPACE=/home/lg/working_dir

PATH=$WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$WORKSPACE/depot_tools/:/usr/local/go/bin:$WORKSPACE/mtool/bin:$PATH

export GOMA_SERVER_HOST=$SERVER_HOST_GOMA
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

OUT_PRESENT=0
test -d out/bromite && OUT_PRESENT=1
if [[ OUT_PRESENT -eq 0 ]]; then

   echo -e ${RED} -------- sync out folder ${NC}
   test -d ../../artifacs/out/bromite && \
      mkdir -p out/bromite && \
      cp -arp ../../artifacs/out/bromite/* out/bromite/

   echo -e ${RED} -------- gn gen ${NC}
   gn gen --args="import(\"/home/lg/working_dir/bromite/build/GN_ARGS\") use_goma=true goma_dir=\"$WORKSPACE/goma\" $(cat ../../build_args.gni) " out/bromite

   echo -e ${RED} -------- gn args ${NC}
   gn args out/bromite/ --list --short
   gn args out/bromite/ --list >$WORKSPACE/artifacs/gn_list

   echo -e ${RED} -------- apply .mtool ${NC}
   test -f out/bromite/.mtool && \
      cp out/bromite/.mtool .mtool && \
      $WORKSPACE/mtool/chromium/mtime.sh --restore

fi

if [[ -z "${GOMAJOBS}" ]]; then
    GOMAJOBS=40
fi

echo -e ${RED} -------- pre-cache toolchain ${NC}
sudo ../../casupload --cas-server=unix:/tmp/proxy/bots.sock --instance=default_instance \
        third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include \
        third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/include \
        third_party/llvm-build/Release+Asserts/lib \
        third_party/llvm-build/Release+Asserts/bin \
        buildtools/third_party/libc++ \
	chrome/android/profiles/afdo.prof


echo -e ${RED} -------- start build ${NC}
autoninja -j $GOMAJOBS -C out/bromite chrome_public_apk
echo -e ${RED} -------- end build ${NC}

wget http://127.0.0.1:8088/logz?INFO -O ../../artifacs/goma-client.log
cp out/bromite/apks/* $WORKSPACE/artifacs/

echo -e ${RED} -------- generating breakpad symbols ${NC}
autoninja -j $GOMAJOBS -C out/bromite minidump_stackwalk dump_syms
components/crash/content/tools/generate_breakpad_symbols.py --build-dir=out/bromite \
   --symbols-dir=$WORKSPACE/artifacs/symbols/ --binary=out/bromite/lib.unstripped/libchrome.so --clear --verbose
cp out/bromite/lib.unstripped/libchrome.so $WORKSPACE/artifacs/symbols/libchrome.lib.so
cp out/bromite/minidump_stackwalk $WORKSPACE/artifacs/symbols
cp out/bromite/dump_syms $WORKSPACE/artifacs/symbols

echo -e ${RED} -------- sync out folder ${NC}
$WORKSPACE/mtool/chromium/mtime.sh --backup
mv .mtool out/bromite/
cp -arp out/bromite $WORKSPACE/artifacs/out

echo -e ${RED} -------- stop goma ${NC}
$WORKSPACE/goma/goma_ctl.py ensure_stop
