#!/bin/bash

#docker stop gh-proxy

SYSBOX_UID=$(cat /etc/subuid | grep sysbox | cut -d : -f 2)
mkdir -p /tmp/proxy
mkdir -p /tmp/forward-proxy
mkdir -p ~/redis

sudo chown $SYSBOX_UID:$SYSBOX_UID /tmp/proxy
sudo chown $SYSBOX_UID:$SYSBOX_UID /tmp/forward-proxy
sudo chown $SYSBOX_UID:$SYSBOX_UID ~/redis

docker run --rm -d --runtime=sysbox-runc \
  --name=gh-proxy \
  -e "REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR" \
  -v /tmp/proxy:/tmp/proxy:rw \
  -v /tmp/forward-proxy:/tmp/forward-proxy:rw \
  uazo/privoxy

while true
do

  docker run --runtime=sysbox-runc --name=gh-runner -ti --rm \
    --env-file=.env \
    -v ~/docker-inner/:/var/lib/docker/:rw \
    -v /storage/images:/storage/images:rw \
    -v /tmp/proxy:/tmp/proxy:rw \
    -v /tmp/forward-proxy:/tmp/forward-proxy:rw \
    -v ~/redis:/redis:rw \
    --network none \
    uazo/github-runner

  sleep 5s

done
