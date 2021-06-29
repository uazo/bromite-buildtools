ARG VERSION
FROM uazo/build-deps:$VERSION

ARG REMOTEEXEC_ADDR

ENV REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR
ENV DEBIAN_FRONTEND=noninteractive

USER lg
COPY buildbox-casd .

RUN sudo apt-get -f -y install libgoogle-glog-dev libprotobuf17 libgrpc++1 socat &&\
    sudo chmod +x buildbox-casd

CMD sudo rm -rf /wrk-cache/* &&\
    bash -c "socat UNIX-LISTEN:/wrk-cache/bots.sock,reuseaddr,fork TCP4:$REMOTEEXEC_ADDR &" &&\
    ./buildbox-casd \
       --instance=default_instance \
       --cas-instance=default_instance \
       --cas-remote=http://$REMOTEEXEC_ADDR \
       --ra-remote=http://$REMOTEEXEC_ADDR \
       --verbose \
       /wrk-cache
   

