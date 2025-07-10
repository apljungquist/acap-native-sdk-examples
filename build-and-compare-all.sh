#!/usr/bin/env bash
set -eux

export EXREPO=acap-native-examples
for arch in armv7hf aarch64; do
  EXNAME=reproducible-package ./build-and-compare-one.sh $arch
  EXNAME=shell-script-example ./build-and-compare-one.sh $arch
done