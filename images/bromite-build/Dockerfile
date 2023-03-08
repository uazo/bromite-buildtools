ARG BROMITE_SHA
ARG VERSION

FROM uazo/bromite:$VERSION-$BROMITE_SHA

ARG HTTP_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTP_PROXY
ENV https_proxy=$HTTP_PROXY

USER lg
WORKDIR /home/lg/working_dir

COPY pre-start.sh .
COPY start-build.sh .
COPY goma_auth.py .
COPY casupload .
COPY build_args.gni .

COPY generic_android31.textpb .

ENV CIPD_CACHE_DIR=/home/lg/working_dir/.cipd_cache
ENV VPYTHON_VIRTUALENV_ROOT=/home/lg/vpython_root

RUN sudo chmod +x ./start-build.sh \
    && \
    sudo chmod +x ./pre-start.sh \
    && \
    sudo chmod 775 ./goma_auth.py \
    && \
    ./pre-start.sh

