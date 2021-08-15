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

echo -e ${RED} -------- download goma client ${NC}
cd $WORKSPACE
cipd install infra/goma/client/linux-amd64 -root $WORKSPACE/goma

echo "nomatter" >$WORKSPACE/.debug_auth_file
sudo cp $WORKSPACE/goma_auth.py $WORKSPACE/goma/

echo -e ${RED} -------- prepare vpython virtual environment
rm -rf /tmp/vpython*
cd $WORKSPACE/chromium/src
vpython -vpython-spec .vpython -vpython-root . -vpython-log-level debug -vpython-tool install
