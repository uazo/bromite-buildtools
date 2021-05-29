#!/bin/bash

#------------------
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
cd depot_tools/
git apply ../bromite-buildtools/depot_tools.diff
cd ..
PATH=$PWD/chromium/src/third_party/llvm-build/Release+Asserts/bin:$PWD/depot_tools/:/usr/local/go/bin:$PATH
#------------------

cipd install infra/goma/client/linux-amd64 -root ~/goma

cat "nomatter" >~/.debug_auth_file

export GOMA_SERVER_HOST=127.0.0.1
export GOMA_SERVER_PORT=5050
export GOMA_USE_SSL=false
export GOMA_HTTP_AUTHORIZATION_FILE=~/.debug_auth_file
export GOMA_HERMETIC=error
export GOMA_USE_LOCAL=false
export GOMA_FALLBACK=true
export GOMA_ARBITRARY_TOOLCHAIN_SUPPORT=true

~/goma/goma_ctl.py ensure_stop
~/goma/goma_ctl.py ensure_start
