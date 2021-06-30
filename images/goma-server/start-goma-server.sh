#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#export REDISHOST=localhost

echo -e ${RED} -------- start goma-server ${NC}

socat UNIX-LISTEN:/tmp/proxy/bots.sock,reuseaddr,fork TCP4:$REMOTEEXEC_ADDR &

cd ./goma-server/
/usr/local/go/bin/go run ./cmd/remoteexec_proxy/main.go \
   --port 5050 \
   --remoteexec-addr $REMOTEEXEC_ADDR \
   --remote-instance-name default_instance \
   --insecure-remoteexec \
   --allowed-users ppp \
   --exec-config-file "./config-file" \
   --exec-check-cache-timeout 180s \
   --exec-max-retry-count 1 \
   --exec-execute-timeout 180s \
   --exec-upload-blobs-timeout 600s

cd ..

