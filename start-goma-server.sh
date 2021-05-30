#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#export GOPATH=~/go
#export GOCACHE=~/go
export REDISHOST=localhost

echo -e ${RED} -------- cloning goma-server ${NC}

git clone https://github.com/uazo/goma-server

echo -e ${RED} -------- start goma-server ${NC}

cd ./goma-server/
go run ./cmd/remoteexec_proxy/main.go --port 5050 --remoteexec-addr $REMOTEEXEC_ADDR --remote-instance-name default_instance --insecure-remoteexec --allowed-users ppp --exec-config-file "./config-file" --exec-check-cache-timeout 30s --exec-max-retry-count 50 --exec-execute-timeout 600s >log.txt 2>&1 &
