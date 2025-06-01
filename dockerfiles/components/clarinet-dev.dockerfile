# This image is build in Clarinet CI with the `clarinet` artifact built in the `dist_clarinet` job

FROM debian:bookworm-slim

RUN apt update && apt install -y libssl-dev tini

COPY clarinet /bin/

WORKDIR /workspace

ENV CLARINET_MODE_CI=1

# Tini ensures that the default signal handlers works, and reap zombie processes
ENTRYPOINT ["tini", "-", "clarinet"]
