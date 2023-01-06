#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster
TAG=latest

echo "pull image ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG}"
docker pull ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} > /dev/null

docker run -it \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=bash \
  ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} ${@}
