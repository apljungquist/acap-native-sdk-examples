ARG ARCH=armv7hf
ARG VERSION=12.0.0
ARG UBUNTU_VERSION=24.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM rust:1.82.0-bullseye AS build
RUN cargo install \
    --locked \
    --git https://github.com/AxisCommunications/acap-rs.git \
    --branch bypass-eap-create \
    acap-build

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION} AS final
RUN find /opt/axis/acapsdk/sysroots/x86_64-pokysdk-linux/ -name acap-build -delete
COPY --from=build /usr/local/cargo/bin/acap-build /usr/bin/
ENV RUST_BACKTRACE=1 RUST_LOG=debug
