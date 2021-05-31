#!/bin/bash

echo -e ${RED} -------- set envs ${NC}
PATH=$GITHUB_WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$GITHUB_WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

cipd install infra/goma/client/linux-amd64 -root $GITHUB_WORKSPACE/goma

echo "nomatter" >$GITHUB_WORKSPACE/.debug_auth_file
sudo cp $GITHUB_WORKSPACE/bromite-buildtools/goma_auth.py $GITHUB_WORKSPACE/goma/
