FROM ubuntu:20.04
RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 sudo

COPY bytecode_builtins_list_generator .
COPY gen-regexp-special-case .
COPY torque .

ENTRYPOINT ["bash"]
