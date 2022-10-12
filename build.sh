#!/usr/bin/env sh

. ./VERSION

docker build . \
    --build-arg IMAGE_NAME=${IMAGE_NAME} \
    --build-arg IMAGE_VERSION=${VERSION} \
    -t ${REGISTRY_NAME}/${IMAGE_NAME}:latest \
    -t ${REGISTRY_NAME}/${IMAGE_NAME}:${VERSION}
