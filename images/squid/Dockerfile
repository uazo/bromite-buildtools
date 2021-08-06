FROM ubuntu:latest

COPY whitelist /etc/squid/whitelist
COPY squid.conf /etc/squid/squid.conf
COPY start-proxy.sh .

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y squid bash sudo socat

CMD sudo chmod +x ./start-proxy.sh &&\
    ./start-proxy.sh
