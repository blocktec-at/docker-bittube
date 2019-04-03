FROM ubuntu:16.04 as builder

ARG BUILD_DATE
ARG VCS_REF

ARG REPO=ipbc-dev/bittube
ENV REPO=${REPO}	  

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
ARG NPROC
RUN TAG=$(curl -L --silent "https://api.github.com/repos/$REPO/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') && \
    git clone --single-branch --branch $TAG https://github.com/$REPO /src && \	
    cd /src && \
	git submodule init && \ 
	git submodule update && \
	rm -rf build && \        
    if [ -z "$NPROC" ];then make -j$(nproc);else make -j$NPROC;fi

FROM ubuntu:16.04


# Good docker practice, plus we get microbadger badges
LABEL org.label-schema.name = "bittube daemon and cli" \
	  org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/blocktec-at/docker-bittube.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="2.2-r1"							 
											  

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt

COPY --from=builder /src/build/Linux/_no_branch_/release/bin/* /usr/local/bin/

# Contains the blockchain
VOLUME /root/.bittube

# Generate your wallet via accessing the container and run:
# cd /wallet
# bittube-wallet-cli
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081

ENTRYPOINT ["bittubed", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=18080", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--non-interactive", "--confirm-external-bind"] 
