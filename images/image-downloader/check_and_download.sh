#!/bin/bash

while true
do

   VERSION=$(curl -s https://omahaproxy.appspot.com/all.json | jq '.[] | select(.os | contains("win64")) | .versions[] | select(.channel | contains("stable")) | .current_version' | xargs)
   echo Check for $VERSION

   docker -H unix:///home/$USER/gh-runner-ci/var/run/docker.sock pull uazo/build-deps:$VERSION
   docker -H unix:///home/$USER/gh-runner-ci/var/run/docker.sock pull uazo/chromium:$VERSION

   docker -H unix:///home/$USER/gh-runner/var/run/docker.sock pull uazo/build-deps:$VERSION
   docker -H unix:///home/$USER/gh-runner/var/run/docker.sock pull uazo/chromium:$VERSION

   sleep 1h

done
