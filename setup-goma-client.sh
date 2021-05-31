#!/bin/bash

echo -e ${RED} -------- set envs ${NC}
PATH=$GITHUB_WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$GITHUB_WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

cipd install infra/goma/client/linux-amd64 -root $GITHUB_WORKSPACE/goma

cat "nomatter" >$GITHUB_WORKSPACE/.debug_auth_file
sudo cp $GITHUB_WORKSPACE/bromite-buildtools/goma_auth.py $GITHUB_WORKSPACE/goma/

export GOMA_SERVER_HOST=127.0.0.1
export GOMA_SERVER_PORT=5050
export GOMA_USE_SSL=false
export GOMA_HTTP_AUTHORIZATION_FILE=$GITHUB_WORKSPACE/.debug_auth_file
export GOMA_HERMETIC=error
export GOMA_USE_LOCAL=false
export GOMA_FALLBACK=true
export GOMA_ARBITRARY_TOOLCHAIN_SUPPORT=true

$GITHUB_WORKSPACE/goma/goma_ctl.py ensure_stop
$GITHUB_WORKSPACE/goma/goma_ctl.py ensure_start
