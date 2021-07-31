#!/bin/bash

test -e /tmp/forward-proxy/proxy.sock && sudo rm /tmp/forward-proxy/proxy.sock
test -e /tmp/proxy/bots.sock && sudo rm /tmp/proxy/bots.sock

socat UNIX-LISTEN:/tmp/forward-proxy/proxy.sock,reuseaddr,fork TCP:127.0.0.1:8118 &
socat UNIX-LISTEN:/tmp/proxy/bots.sock,reuseaddr,fork TCP4:$REMOTEEXEC_ADDR &

sudo chmod 777 /tmp/forward-proxy/proxy.sock
sudo chmod 777 /tmp/proxy/bots.sock

privoxy --no-daemon privoxy.conf
