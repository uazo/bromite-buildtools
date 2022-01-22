#!/bin/bash

if [[ -z "${DOCKER_SOCK}" ]]; then
   echo "Please set DOCKER_SOCK env variable"
   exit 1
fi

if [[ -z "${DEV_CONTAINER}" ]]; then
   echo "Please set DEV_CONTAINER env variable"
   exit 1
fi

sudo docker -H $DOCKER_SOCK cp $DEV_CONTAINER:/home/lg/working_dir/chromium/src/out/bromite/bromite.idx .
sudo docker -H $DOCKER_SOCK cp $DEV_CONTAINER:/home/lg/working_dir/bromite/build/RELEASE .

#INDEX_VERSION=$(cat RELEASE)
DOCKER_BUILDKIT=1 docker build -t uazo/bromite-remote-index:$INDEX_VERSION \
                --progress plain \
                --no-cache \
                .
