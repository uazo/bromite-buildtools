ARG VERSION
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

COPY buildbox-casd .
COPY set-perms.sh .

RUN apt-get update &&\
    apt-get -f -y install sudo libgoogle-glog-dev libprotobuf17 libgrpc++1 socat &&\
    sudo chmod +x buildbox-casd &&\
    sudo chmod +x set-perms.sh

CMD sudo rm -rf /wrk-cache/* &&\
    bash -c "socat UNIX-LISTEN:/wrk-cache/bots.sock,reuseaddr,fork TCP4:$REMOTEEXEC_ADDR &" &&\
    bash -c "$PWD/set-perms.sh &" &&\
    ./buildbox-casd \
       --instance=default_instance \
       --cas-instance=default_instance \
       --cas-remote=http://$REMOTEEXEC_ADDR \
       --ra-remote=http://$REMOTEEXEC_ADDR \
       --verbose \
       /wrk-cache
