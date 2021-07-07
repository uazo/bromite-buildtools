ARG VERSION

FROM uazo/chromium:$VERSION

ARG BROMITE_SHA
ENV BROMITE_SHA=$SHA

USER lg

COPY apply-bromite-patches.sh .

RUN sudo chmod +x ./apply-bromite-patches.sh \
    && \
    mkdir bromite && \
    cd bromite && \
    git init && \
    git remote add origin https://github.com/uazo/bromite && \
    git fetch origin $BROMITE_SHA && \
    git reset --hard FETCH_HEAD && \
    && \
    ./apply-bromite-patches.sh

