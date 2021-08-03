FROM ubuntu:latest

ARG REMOTEEXEC_ADDR

COPY user.action .
COPY privoxy.conf .
COPY start-proxy.sh .

RUN apt-get update && apt-get install -y privoxy bash sudo socat

#RUN useradd -u 2000 -m ghproxy \
#    && usermod -aG sudo ghproxy \
#    && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers

#RUN useradd -m runner1 \
#    && usermod -aG sudo runner1
#
#USER ghproxy

CMD sudo chmod +x ./start-proxy.sh &&\
    REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR &&\
    ./start-proxy.sh
