#!/bin/bash

if [[ -z "${INDEX_VERSION}" ]]; then
   echo "Please set INDEX_VERSION env variable"
   exit 1
fi

if [[ -z "${DEV_CONTAINER}" ]]; then
   echo "Please set DEV_CONTAINER env variable"
   exit 1
fi

cp /storage/images/android/x64/$INDEX_VERSION/bromite.idx .
cp /storage/images/android/x64/$INDEX_VERSION/RELEASE

DOCKER_BUILDKIT=1 docker build -t uazo/bromite-remote-index:$INDEX_VERSION \
                --progress plain \
                --no-cache \
                .
