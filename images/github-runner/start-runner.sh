#!/bin/bash

while true
do

  docker run --runtime=sysbox-runc --name=gh-runner -ti --rm \
    --env-file=.env \
    -v ~/docker-inner/:/var/lib/docker/ \
    -v /storage/images:/storage/images \
    -v /tmp/forward-proxy:/tmp/forward-proxy \
    -v /tmp/proxy:/tmp/proxy \
    --network none \
    uazo/github-runner

  sleep 5s

done
