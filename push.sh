#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster

docker push \
    ${REGISTRY_NAME}/${IMAGE_NAME}:latest
