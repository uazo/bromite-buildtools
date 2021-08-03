ARG VERSION
FROM uazo/build-deps:$VERSION

ENV DEBIAN_FRONTEND=noninteractive

USER lg
COPY buildbox-worker .
COPY buildbox-run-hosttools .

RUN HTTP_PROXY= &&\
    HTTPS_PROXY= &&\
    http_proxy= &&\
    https_proxy= &&\
    sudo rm /etc/apt/apt.conf.d/proxy.conf

RUN sudo apt-get -f -y install libgoogle-glog-dev libprotobuf17 libgrpc++1 &&\
    sudo chmod +x buildbox-worker &&\
    sudo chmod +x buildbox-run-hosttools

USER root

CMD PATH=.:$PATH &&\
    ./buildbox-worker \
       --instance=default_instance \
       --bots-remote=unix:/wrk-cache/bots.sock \
       --stop-after=50 \ 
       --bots-retry-limit=5 \
       --buildbox-run=buildbox-run-hosttools \
       --cas-remote=unix:/wrk-cache/casd.sock \
       --logstream-remote=unix:/wrk-cache/casd.sock \
       --cas-instance=default_instance \
       --cas-retry-limit=10
