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
    apt-get -f -y install sudo lsb-release cl-base64 bash wget apt-utils python sed tzdata build-essential lib32gcc-9-dev g++-multilib dos2unix wiggle

ENV user lg

RUN useradd -m -d /home/${user} ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    chmod 4755 /usr/bin/sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${user}

#RUN mkdir -p /home/${user} && \
#    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/${user}

RUN wget https://raw.githubusercontent.com/chromium/chromium/$VERSION/build/install-build-deps.sh && \
    wget https://raw.githubusercontent.com/chromium/chromium/$VERSION/build/install-build-deps.py && \
    sed -i 's/snapcraft/wget/' install-build-deps.sh && \
    chmod +x ./install-build-deps.sh && \
    chmod +x ./install-build-deps.py && \
    sudo ./install-build-deps.sh --no-prompt --lib32 --no-chromeos-fonts && \
    sudo ./install-build-deps.sh --android --no-prompt --no-chromeos-fonts && \
    sudo mkdir -p /github/home/.vscode-server && \
    sudo chown lg /github/home/.vscode-server

