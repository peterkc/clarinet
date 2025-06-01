# region :: builder
# --------------------------------------------------------
FROM rust:bookworm as builder

# region :: Shell, User
SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]
USER root
# endregion

# region :: Build Platform, Target
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETPLATFORM
ARG TARGETOS
# endregion

ARG GIT_COMMIT
RUN test -n "$GIT_COMMIT" || (echo "GIT_COMMIT not set" && false)

RUN echo "Building stacks-node from commit: https://github.com/stacks-network/stacks-blockchain/commit/$GIT_COMMIT"

WORKDIR /stacks
RUN git init && \
    git remote add origin https://github.com/stacks-network/stacks-blockchain.git && \
    git fetch --depth=1 origin "$GIT_COMMIT" && \
    git reset --hard FETCH_HEAD

RUN cargo build --package stacks-node --bin stacks-node --features monitoring_prom,slog_json --release
# endregion

# region :: main    
# --------------------------------------------------------
FROM debian:bookworm-slim

COPY --from=builder /stacks/target/release/stacks-node /bin

RUN apt update && apt install -y tini
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root
# endregion