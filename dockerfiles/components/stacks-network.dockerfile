FROM rust:bullseye as build

COPY . ./

RUN cargo build --release --manifest-path ./components/stacks-network/Cargo.toml

# prod stage
FROM debian:bullseye-slim

RUN apt update && apt install -y tini

COPY --from=build target/release/stacks-network /

# Tini ensures that the default signal handlers works, and reap zombie processes
ENTRYPOINT ["tini", "-", "./stacks-network"]