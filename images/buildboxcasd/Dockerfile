ARG VERSION
FROM localhost:5000/uazo/build-deps:$VERSION

ARG REMOTEEXEC_ADDR

ENV REMOTEEXEC_ADDR=$REMOTEEXEC_ADDR
ENV DEBIAN_FRONTEND=noninteractive

USER lg
COPY buildbox-casd .

RUN sudo apt-get -f -y install libgoogle-glog-dev libprotobuf17 libgrpc++1 &&\
    sudo chmod +x buildbox-casd

CMD ./buildbox-casd \
       --instance=default_instance \
       --cas-instance=default_instance \
       --cas-remote=http://$REMOTEEXEC_ADDR \
       --ra-remote=http://$REMOTEEXEC_ADDR \
       --verbose \
       /wrk-cache
   

