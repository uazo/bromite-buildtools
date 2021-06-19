#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

WORKSPACE=/home/lg/working_dir

PATH=$WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

sudo apt-get install -y lsof libgoogle-glog-dev libprotobuf17 libgrpc++1
cipd install infra/goma/client/linux-amd64 -root $WORKSPACE/goma

echo "nomatter" >$WORKSPACE/.debug_auth_file
sudo cp $WORKSPACE/goma_auth.py $WORKSPACE/goma/

cd chromium/src

echo -e ${RED} -------- gn gen ${NC}
gn gen --args="$(cat ../../bromite/build/GN_ARGS) target_cpu=\"x86\" use_goma=true goma_dir=\"$WORKSPACE/goma\" " out/bromite
