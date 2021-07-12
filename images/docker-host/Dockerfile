#FROM nestybox/ubuntu-focal-systemd-docker
FROM ubuntu:20.04

RUN set -xe && \
    echo '#!/bin/sh' > /usr/sbin/policy-rc.d && \
    echo 'exit 101' >> /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d && \
    dpkg-divert --local --rename --add /sbin/initctl && \
    cp -a /usr/sbin/policy-rc.d /sbin/initctl && \
    sed -i 's/^exit.*/exit 0/' /sbin/initctl && \
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && \
    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean && \
    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean && \
    echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean && \
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages && \
    echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes && \
    echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      systemd systemd-sysv libsystemd0 ca-certificates dbus \
      iptables iproute2 kmod locales sudo udev && \
    echo "ReadKMsg=no" >> /etc/systemd/journald.conf && \
    apt-get clean -y && \
    rm -rf /var/cache/debconf/* /var/lib/apt/lists/* /var/log/* /tmp/* /var/tmp/* \
           /usr/share/doc/* /usr/share/man/* /usr/share/local/* && \
    useradd --create-home --shell /bin/bash admin && \
    echo "admin:admin" | chpasswd && \
    adduser admin sudo

STOPSIGNAL SIGRTMIN+3

RUN apt-get update && \
    apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
      curl gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io=1.4.4-1 && \
    apt-get clean -y && \
    rm -rf /var/cache/debconf/* /var/lib/apt/lists/* /var/log/* /tmp/* /var/tmp/* \
           /usr/share/doc/* /usr/share/man/* /usr/share/local/* && \
    usermod -a -G docker admin

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        openssh-server && \
    mkdir /home/admin/.ssh && \
    chown admin:admin /home/admin/.ssh

# Extra deps
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    sudo \
    pigz \
    && rm -rf /var/lib/apt/list/*

ENTRYPOINT ["/sbin/init", "--log-level=err"]
CMD ["/bin/bash"]
