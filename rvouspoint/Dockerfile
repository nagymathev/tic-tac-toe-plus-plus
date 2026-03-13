FROM rust:latest AS builder
WORKDIR /usr/src/rvouspoint
COPY . .
RUN cargo install --path .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install libc6 && rm -rf /var/lib/apt/list/*
COPY --from=builder /usr/local/cargo/bin/rvouspoint /usr/local/bin/rvouspoint
CMD [ "rvouspoint" ]
