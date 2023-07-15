FROM debian:stable
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y cron python3 python3-requests unzip nginx-light wget unzip
# We install pip, jinja and delete pip afterwards in same step to keep final
# image size small.
RUN apt-get install -y --no-install-recommends python3-pip && \
    pip3 install j2cli --break-system-packages && apt-get remove -y python3-pip && apt-get autoremove -y
RUN rm -rf /var/www/html/*
#WORKDIR "/"

RUN wget https://github.com/clangd/clangd/releases/download/snapshot_20211205/clangd_indexing_tools-linux-snapshot_20211205.zip && \
    unzip clangd_indexing_tools-linux-snapshot_20211205.zip && \
    rm clangd_indexing_tools-linux-snapshot_20211205.zip

ADD bromite.idx .
ADD entry_point.sh .

RUN chmod +x ./entry_point.sh

ENTRYPOINT ["./entry_point.sh"]
