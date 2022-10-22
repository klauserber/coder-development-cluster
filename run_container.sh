#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster

ENTRYPOINT=${1:-/app/run.sh}

docker run -it \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=${ENTRYPOINT} \
  ${REGISTRY_NAME}/${IMAGE_NAME}:latest ${@:2}
