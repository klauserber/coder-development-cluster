#!/usr/bin/env sh

. ./VERSION

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
    -t ${REGISTRY_NAME}/${IMAGE_NAME}:${VERSION} \
    --platform=linux/${ARCH}
