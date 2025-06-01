FROM debian:bookworm-slim

RUN apt update && apt install -y libssl-dev tini

RUN rustup update stable && rustup default stable

COPY clarinet /bin/

WORKDIR /workspace

ENV CLARINET_MODE_CI=1

# Tini ensures that the default signal handlers works, and reap zombie processes
ENTRYPOINT ["tini", "-", "clarinet"]
