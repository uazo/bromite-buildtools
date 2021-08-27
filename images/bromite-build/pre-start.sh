#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

WORKSPACE=/home/lg/working_dir
PATH=$WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

sudo apt-get install -y lsof libgoogle-glog-dev libprotobuf17 libgrpc++1 parallel golang-go

echo -e ${RED} -------- download mtool ${NC}
git clone https://github.com/bromite/mtool
cd mtool
make
cd ..

mkdir $CIPD_CACHE_DIR
mkdir $VPYTHON_VIRTUALENV_ROOT

echo -e ${RED} -------- download goma client ${NC}
cd $WORKSPACE
cipd install infra/goma/client/linux-amd64 -root $WORKSPACE/goma

echo "nomatter" >$WORKSPACE/.debug_auth_file
sudo cp $WORKSPACE/goma_auth.py $WORKSPACE/goma/

echo -e ${RED} -------- prepare vpython virtual environment ${NC}
rm -rf /tmp/vpython*
cd $WORKSPACE/chromium/src
vpython -vpython-spec .vpython -vpython-root . -vpython-log-level debug -vpython-tool install

#echo -e ${RED} -------- download x86_64 android image ${NC}
#echo -e "\$ParanoidMode CheckIntegrity\n\nchromium/third_party/android_sdk/public/avds/android-31/google_apis/x86_64 Ur_zl6_BRKRkf_9X3SMZ3eH2auoOyJ2kLslpTZZwi3gC" | .cipd_client ensure -ensure-file - -root $WORKSPACE/chromium/src/.android
#echo -e "\$ParanoidMode CheckIntegrity\n\nchromium/third_party/android_sdk/public/emulator gMHhUuoQRKfxr-MBn3fNNXZtkAVXtOwMwT7kfx8jkIgC\nchromium/third_party/android_sdk/public/system-images/android-31/google_apis/x86_64 R6Jh5_P21Euu-kdb11zcNjdJKN4vV1mdQTb8t4gph4IC" | .cipd_client ensure -ensure-file - -root $WORKSPACE/chromium/src/.emulator_sdk
