ARG VERSION

FROM uazo/chromium:$VERSION

ARG BROMITE_SHA
ENV BROMITE_SHA=$BROMITE_SHA

#USER lg
WORKDIR /home/lg/working_dir

COPY apply-bromite-patches.sh .

RUN sudo chmod +x ./apply-bromite-patches.sh && \
    mkdir bromite && \
    cd bromite && \
    git init && \
    git remote add origin https://github.com/uazo/bromite && \
    git fetch origin $BROMITE_SHA && \
    git reset --hard FETCH_HEAD && \
    cd ..

RUN ./apply-bromite-patches.sh

