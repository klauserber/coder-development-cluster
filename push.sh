#!/usr/bin/env bash

. ./VERSION

docker push \
    ${REGISTRY_NAME}/${IMAGE_NAME}:latest

docker push \
    ${REGISTRY_NAME}/${IMAGE_NAME}:${VERSION}
