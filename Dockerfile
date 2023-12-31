# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM rust:1.71 AS buildbase
RUN apt update && apt install -y musl-tools musl-dev iputils-ping
WORKDIR /src
RUN rustup target add wasm32-wasi

FROM buildbase AS build
COPY Cargo.toml orders.json update_order.json .
COPY src ./src
# Build the Wasm binary
RUN cargo build --target wasm32-wasi --release
# This line builds the AOT Wasm binary
RUN cp target/wasm32-wasi/release/order_demo_service.wasm order_demo_service.wasm
RUN chmod a+x order_demo_service.wasm

# FROM scratch
FROM --platform=$BUILDPLATFORM rust:1.71
ENTRYPOINT [ "/order_demo_service.wasm" ]
COPY --link --from=build /src/order_demo_service.wasm /order_demo_service.wasm
