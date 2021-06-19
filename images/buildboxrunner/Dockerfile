ARG VERSION
FROM localhost:5000/uazo/build-deps:$VERSION

ARG REMOTEEXEC_ADDR

ENV REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR
ENV DEBIAN_FRONTEND=noninteractive

USER lg
COPY buildbox-worker .
COPY buildbox-run-hosttools .

RUN sudo apt-get -f -y install libgoogle-glog-dev libprotobuf17 libgrpc++1 &&\
    sudo chmod +x buildbox-worker &&\
    sudo chmod +x buildbox-run-hosttools

CMD PATH=.:$PATH &&\
    ./buildbox-worker \
       --instance=default_instance \
       --bots-remote=http://$REMOTEEXEC_ADDR \
       --bots-retry-limit=10 \
       --buildbox-run=buildbox-run-hosttools \
       --cas-remote=unix:/wrk-cache/casd.sock \
       --logstream-remote=unix:/wrk-cache/casd.sock \
       --cas-instance=default_instance \
       --cas-retry-limit=10
