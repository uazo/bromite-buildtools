#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

cd chromium/src

gn gen --args="$(cat ~/bromite/build/GN_ARGS) target_cpu=\"x86\" use_goma=true goma_dir=\"$PWD/goma\" " out/x86

autoninja -j 40 -C out/x86 chrome_public_apk
