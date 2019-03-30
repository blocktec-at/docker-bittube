FROM ubuntu:bionic

LABEL maintainer="blocktec"

# Get needed packages
RUN apt-get -qq update \
  && apt-get -qq install \ 
    unzip \ 
    curl \
    libboost-all-dev \
    libssl-dev \
    libpcsclite-dev \
    libc6-dev \
    libunbound-dev \
    libsodium-dev \
    libminiupnpc-dev \
    libunwind8-dev \
    libreadline6-dev \
    liblzma-dev \
    libldns-dev \
    libexpat1-dev \
    build-essential \
    libzmq3-dev \
    libdb-dev \
    graphviz \
    doxygen \
    libtool-bin \
    autoconf \
    automake \
    jq \
    nano

# Create app and data directory
RUN mkdir -p /daemon/data

# Install Daemon
WORKDIR /daemon/
RUN curl -L -o daemon.zip https://github.com/ipbc-dev/bittube/releases/download/2.1.0.1/bittube-linux-x64-v2.1.0.1.zip \
  && unzip daemon.zip -d /daemon \
  && chown -R daemon /daemon \
  && chmod +x /daemon/* \
  && rm -f daemon.zip

USER daemon

EXPOSE 18080 18081 18082
VOLUME [ "/daemon/data" ]
