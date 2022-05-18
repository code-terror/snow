# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl git-all build-essential binutils-dev libunwind-dev libblocksruntime-dev liblzma-dev
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install honggfuzz
RUN git clone https://github.com/mcginty/snow.git
WORKDIR /snow
COPY /Mayhem/* /Mayhem/
WORKDIR /snow/hfuzz
RUN RUSTFLAGS="-Znew-llvm-pass-manager=no" HFUZZ_RUN_ARGS="--run_time $run_time --exit_upon_crash" ${HOME}/.cargo/bin/cargo hfuzz build
# Package Stage
FROM ubuntu:20.04

COPY --from=builder /snow/hfuzz/hfuzz_target/x86_64-unknown-linux-gnu/release/* /
COPY --from=builder /snow/Mayhem/* /

