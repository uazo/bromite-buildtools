#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
#    GITHUB_SHA=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.head.sha)
#fi

#sudo apt-get install -y libxkbcommon-x11-0 libxkbcommon-dev

echo -e ${RED} -------- set envs ${NC}
PATH=$GITHUB_WORKSPACE/chromium/src/third_party/llvm-build/Release+Asserts/bin:$GITHUB_WORKSPACE/depot_tools/:/usr/local/go/bin:$PATH

bash ./bromite-buildtools/start-goma-server.sh
bash ./bromite-buildtools/setup-goma-client.sh
bash ./bromite-buildtools/start_proxy.sh

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

cd chromium/src

echo -e ${RED} -------- gn gen ${NC}
gn gen --args="$(cat ../../bromite/build/GN_ARGS) target_cpu=\"x86\" use_goma=true goma_dir=\"$GITHUB_WORKSPACE/goma\" " out/x86

echo -e ${RED} -------- checking prebuild ${NC}
rm out.$GITHUB_SHA.tar.gz
lftp $FTP_HOST -u $FTP_USER,$FTP_PWD -e "set ftp:ssl-force true; set ssl:verify-certificate false; cd /bromite; get out.x86.$GITHUB_SHA.tar.gz; quit" && OK=1 || OK=0

if [[ OK -eq 1 ]]; then
    echo -e ${RED} -------- unpacking prebuild ${NC}

    tar xf out.x86.$GITHUB_SHA.tar.gz

    # TODO add mtool restore
fi

echo -e ${RED} -------- start build ${NC}
autoninja -j 40 -C out/x86 chrome_public_apk

# TODO add mtool backup

echo -e ${RED} -------- tar out ${NC}
tar -czf out.x86.$GITHUB_SHA.tar.gz ./out

echo -e ${RED} -------- uploading to storage ${NC}
lftp $FTP_HOST -u $FTP_USER,$FTP_PWD -e "set ftp:ssl-force true; set ssl:verify-certificate false; cd /bromite; put out.x86.$GITHUB_SHA.tar.gz; quit"
