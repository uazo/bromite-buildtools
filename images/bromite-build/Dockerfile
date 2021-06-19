ARG VERSION

FROM localhost:5000/uazo/bromite:$VERSION
ARG VERSION
ENV VERSION=$VERSION

USER lg

COPY pre-start.sh .
COPY start-build.sh .
COPY goma_auth.py .
COPY casupload .

RUN sudo chmod +x ./start-build.sh \
    && \
    sudo chmod +x ./pre-start.sh \
    && \
    sudo chmod 775 ./goma_auth.py \
    && \
    ./pre-start.sh

CMD ./start-build.sh

