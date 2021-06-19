ARG VERSION

FROM localhost:5000/uazo/chromium:$VERSION
ARG VERSION
ENV VERSION=$VERSION

USER lg

COPY apply-bromite-patches.sh .

RUN sudo chmod +x ./apply-bromite-patches.sh \
    && \
    git clone https://github.com/bromite/bromite \
    && \
    ./apply-bromite-patches.sh

