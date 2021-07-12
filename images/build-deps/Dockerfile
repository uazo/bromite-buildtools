FROM ubuntu:20.04
ARG VERSION

RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get -f -y install sudo lsb-release cl-base64 bash wget apt-utils python sed tzdata build-essential

ENV user lg

RUN useradd -m -d /home/${user} ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${user}

WORKDIR /home/${user}

RUN wget https://chromium.googlesource.com/chromium/src/+/refs/tags/$VERSION/build/install-build-deps.sh?format=TEXT -O install-build-deps.sh.base64 \
    && \
    wget https://chromium.googlesource.com/chromium/src/+/refs/tags/$VERSION/build/install-build-deps-android.sh?format=TEXT -O install-build-deps-android.sh.base64 \
    && \
    sudo base64 -d install-build-deps.sh.base64 >install-build-deps.sh \
    && \
    sudo base64 -d install-build-deps-android.sh.base64 >install-build-deps-android.sh \
    && \
    sed -i 's/snapcraft/wget/' install-build-deps.sh

RUN chmod +x ./install-build-deps.sh && \
    chmod +x ./install-build-deps-android.sh && \
    sudo ./install-build-deps.sh --no-prompt --lib32 && \
    sudo ./install-build-deps-android.sh --no-prompt


   

