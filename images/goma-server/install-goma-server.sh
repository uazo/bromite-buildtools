#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#export GOPATH=~/go
#export GOCACHE=~/go
export REDISHOST=localhost

echo -e ${RED} -------- install go 16.2 ${NC}

wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz

echo -e ${RED} -------- cloning goma-server ${NC}

git clone https://github.com/uazo/goma-server
