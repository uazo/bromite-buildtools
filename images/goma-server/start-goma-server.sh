#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e ${RED} -------- start redis-server ${NC}

export REDISHOST=localhost
sudo redis-server /etc/redis/redis.conf

echo -e ${RED} -------- start goma-server ${NC}

socat TCP-LISTEN:50051,reuseaddr,fork UNIX-CLIENT:/tmp/proxy/bots.sock &

cd ./goma-server/
/usr/local/go/bin/go run ./cmd/remoteexec_proxy/main.go \
   --port 5050 \
   --remoteexec-addr 127.0.0.1:50051 \
   --remote-instance-name default_instance \
   --insecure-remoteexec \
   --allowed-users ppp \
   --exec-config-file "./config-file" \
   --exec-check-cache-timeout 180s \
   --exec-max-retry-count 1 \
   --exec-execute-timeout 180s \
   --exec-upload-blobs-timeout 600s

cd ..

