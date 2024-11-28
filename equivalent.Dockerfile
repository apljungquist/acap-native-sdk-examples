ARG ARCH=armv7hf
ARG VERSION=12.0.0
ARG UBUNTU_VERSION=24.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM rust:1.82.0-bullseye AS build
RUN cargo install \
    --locked \
    --git https://github.com/AxisCommunications/acap-rs.git \
    --rev f9083db416997b8f48f90c8ea3eed879844b912b \
    acap-build

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}
ENV SOURCE_DATE_EPOCH=0

RUN find /opt/axis/acapsdk/sysroots/x86_64-pokysdk-linux/ -name acap-build -delete
COPY --from=build /usr/local/cargo/bin/acap-build /usr/bin/
ENV ACAP_BUILD_IMPL=equivalent RUST_BACKTRACE=1 RUST_LOG=debug
