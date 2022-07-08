FROM ubuntu:20.04
ARG VERSION

ARG HTTP_PROXY

ENV HTTP_PROXY=$HTTP_PROXY
ENV http_proxy=$HTTP_PROXY

ENV HTTPS_PROXY=$HTTP_PROXY
ENV https_proxy=$HTTP_PROXY

RUN touch /etc/apt/apt.conf.d/proxy.conf && \
    echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >/etc/apt/apt.conf.d/proxy.conf

RUN dpkg --add-architecture i386

RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get -f -y install sudo lsb-release cl-base64 bash wget apt-utils python sed tzdata build-essential lib32gcc-9-dev g++-multilib

ENV user lg

RUN useradd -m -d /home/${user} ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${user}

#RUN mkdir -p /home/${user} && \
#    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/${user}

RUN wget https://chromium.googlesource.com/chromium/src/+/refs/tags/$VERSION/build/install-build-deps.sh?format=TEXT -O install-build-deps.sh.base64 \
    && \
    wget https://chromium.googlesource.com/chromium/src/+/refs/tags/$VERSION/build/install-build-deps-android.sh?format=TEXT -O install-build-deps-android.sh.base64 \
    && \
    base64 -d install-build-deps.sh.base64 >install-build-deps.sh && \
    base64 -d install-build-deps-android.sh.base64 >install-build-deps-android.sh && \
    sed -i 's/snapcraft/wget/' install-build-deps.sh && \
    chmod +x ./install-build-deps.sh && \
    chmod +x ./install-build-deps-android.sh && \
    sudo ./install-build-deps.sh --no-prompt --lib32 --no-chromeos-fonts && \
    sudo ./install-build-deps-android.sh --no-prompt


   

