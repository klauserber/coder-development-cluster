#!/usr/bin/env sh

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster

ARCH=${1:-$(uname -m)}
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
fi

echo "Building for $ARCH"

docker build . \
    --build-arg IMAGE_NAME=${IMAGE_NAME} \
    --build-arg IMAGE_VERSION=${VERSION} \
    --build-arg TARGETARCH=${ARCH} \
    -t ${REGISTRY_NAME}/${IMAGE_NAME}:latest \
    --platform=linux/${ARCH}
