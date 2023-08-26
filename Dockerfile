FROM debian:bookworm as builder

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  ca-certificates \
  curl \
  libssl-dev

ARG NMAP_VERSION=7.94

RUN mkdir /build \
  && curl -sSL https://nmap.org/dist/nmap-${NMAP_VERSION}.tgz \
   | tar zxC /build --strip-component 1 \
  && cd /build \
  && ./configure \
  && make -j$(nproc) build-ncat \
  && strip ncat/ncat


FROM debian:bookworm-slim AS base-amd64
ARG ARCH=x86_64


FROM debian:bookworm-slim AS base-arm64
ARG ARCH=aarch64


FROM base-$TARGETARCH
COPY --from=builder \
  /lib/${ARCH}-linux-gnu/libssl.so.3 \
  /lib/${ARCH}-linux-gnu/libcrypto.so.3 \
  /lib/${ARCH}-linux-gnu/
COPY --from=builder \
  /build/ncat/ncat \
  /usr/local/bin/

ENTRYPOINT ["ncat"]
