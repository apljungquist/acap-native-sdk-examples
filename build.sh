#!/usr/bin/env sh
set -eux

EXREPO=acap-native-examples
EXNAME=hello-world

for arch in armv7hf aarch64; do
  export imagetag=${EXREPO}_${EXNAME}:${arch}
  docker image rm -f $imagetag
  cd $EXNAME
  docker build --no-cache --tag $imagetag --build-arg ARCH=${arch} .
  docker cp $(docker create $imagetag):/opt/app ./build
  cd ..
  docker image rm -f $imagetag
  sha256sum ${EXNAME}/build/*.eap > ${EXNAME}-${arch}.eap.sha256sum
done