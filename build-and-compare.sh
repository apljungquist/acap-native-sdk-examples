#!/usr/bin/env bash
set -eux

archs=${1:-armv7hf aarch64}

exrepo=${EXREPO:-acap-native-examples}
exname=${EXNAME:-reproducible-package}

for arch in ${archs}; do
  export imagetag=${exrepo}_${exname}:${arch}
  docker image rm -f $imagetag
  cd ${exname}
  docker build \
    --build-arg ARCH=${arch} \
    --build-arg TIMESTAMP=0 \
    --no-cache \
    --tag $imagetag \
    .
  docker cp $(docker create $imagetag):/opt/app ./build
  docker image rm -f $imagetag
  ls -al {app,build}/
  sha256sum build/*.eap > ${arch}.sha256sum
  rm -r build/
  cd ..
done

git diff --exit-code
