# For production, likely to be
# ARG RUNNER_IMAGE="gcr.io/distroless/cc"
ARG RUNNER_IMAGE="rust:1.45-slim"

FROM rust:1.45 as builder

RUN cargo install boringtun

FROM rust:1.45-slim

RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list

RUN apt update && \
    apt install -y --no-install-recommends procps iproute2 iptables wireguard-tools

RUN apt update && \
    apt install -y --no-install-recommends resolvconf || true ;

COPY --from=builder /usr/local/cargo/bin/boringtun /usr/bin/boringtun

ENV WG_SUDO=1
ENV WG_LOG_LEVEL=debug
ENV WG_THREADS=4
ENV WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun

CMD ["wg-quick", "up", "wg0"]
