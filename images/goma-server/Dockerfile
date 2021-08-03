FROM ubuntu:20.04

COPY install-goma-server.sh .
COPY start-goma-server.sh .
COPY config-file .

RUN apt-get update \
    && \
    apt-get -y install sudo wget git socat redis-server \
    && \
    sudo chmod +x ./install-goma-server.sh \
    && \
    sudo chmod +x ./start-goma-server.sh \
    && \
    ./install-goma-server.sh

CMD ./start-goma-server.sh


