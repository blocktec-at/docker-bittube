# Multistage docker build, requires docker 17.05

# builder stage
FROM ubuntu:16.04

ARG BUILD_DATE
ARG VCS_REF

ARG BRANCH=2.1.0.1
ENV BRANCH=${BRANCH}		  

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install \
        ca-certificates \
	build-essential \
	libboost-all-dev \
	libssl-dev \
	libzmq3-dev \
	libunbound-dev \
	libsodium-dev \
	libunwind8-dev \
	liblzma-dev \
	libreadline6-dev \
	libldns-dev \
	libexpat1-dev \
	libpgm-dev \
        cmake \
        g++ \
        make \
        pkg-config \
        graphviz \
        doxygen \
        git \
        curl \
        libtool-bin \
        autoconf \
        automake \
        bzip2 \
        xsltproc \
        gperf \
        unzip

WORKDIR /usr/local

RUN git clone --recursive https://github.com/ipbc-dev/bittube.git /src

WORKDIR /src

RUN git submodule init && git submodule update && git checkout 2.1.0.1

ARG NPROC
RUN rm -rf build && \
    if [ -z "$NPROC" ];then make -j$(nproc);else make -j$NPROC;fi

COPY . .

# Good docker practice, plus we get microbadger badges
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/blocktec-at/docker-bittube.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="2.2-r1"							 
											  

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt

COPY /build/Linux/_HEAD_detached_at_2.1.0.1_/release/bin /usr/local/bin/

# Contains the blockchain
VOLUME /root/.bittube

# Generate your wallet via accessing the container and run:
# cd /wallet
# bittube-wallet-cli
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081

ENTRYPOINT ["bittubed", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=18080", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--non-interactive", "--confirm-external-bind"] 
