ARG VERSION

FROM uazo/build-deps:$VERSION
ARG VERSION
ENV VERSION=$VERSION

#USER lg
WORKDIR /home/lg/working_dir

COPY prepare-build.sh .
COPY depot_tools.diff .
COPY remove_ninja_uploader.diff .

RUN sudo chmod +x ./prepare-build.sh \
    && \
    ./prepare-build.sh

