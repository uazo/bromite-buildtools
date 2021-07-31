FROM alpine:3.14

ARG REMOTEEXEC_ADDR

COPY user.action .
COPY privoxy.conf .
COPY start-proxy.sh .

RUN apk update && apk add privoxy bash sudo socat

CMD sudo chmod +x ./start-proxy.sh &&\
    REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR &&\
    ./start-proxy.sh
