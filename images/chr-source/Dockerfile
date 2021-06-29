ARG VERSION

FROM uazo/build-deps:$VERSION
ARG VERSION
ENV VERSION=$VERSION

USER lg
WORKDIR working_dir

COPY prepare-build.sh .
COPY depot_tools.diff .

RUN sudo chmod +x ./prepare-build.sh \
    && \
    ./prepare-build.sh

