#!/usr/bin/env bash
set -eux

arch=${1}

exrepo=${EXREPO}
exname=${EXNAME}

export imagetag=${exrepo}_${exname}:${arch}
docker image rm -f $imagetag
cd ${exname}
docker build \
  --build-arg ARCH=${arch} \
  --build-arg TIMESTAMP=0 \
  --no-cache \
  --tag $imagetag \
  .
rm -r ./build/ ||:
docker cp $(docker create $imagetag):/opt/app ./build
docker image rm -f $imagetag
ls -al {app,build}/
sha256sum build/*.eap > ${arch}.sha256sum
#rm -r build/
cd ..

git diff --exit-code
