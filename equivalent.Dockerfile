ARG ARCH=armv7hf
ARG VERSION=12.0.0
ARG UBUNTU_VERSION=24.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM --platform=linux/amd64 rust:1.82.0-bullseye AS build
RUN cargo install \
    --locked \
    --git https://github.com/AxisCommunications/acap-rs.git \
    --rev aa69b242602fa6c8f97f68efeb586b9f7569c6c0 \
    acap-build

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}
ENV SOURCE_DATE_EPOCH=0

RUN find /opt/axis/acapsdk/sysroots/x86_64-pokysdk-linux/ -name acap-build -delete
COPY --from=build /usr/local/cargo/bin/acap-build /usr/bin/
ENV ACAP_BUILD_IMPL=equivalent RUST_BACKTRACE=1 RUST_LOG=debug
