#!/usr/bin/env bash

./build.sh

. ./VERSION

ENTRYPOINT=${1:-/app/run_destroy.sh}

docker run -it -v $(pwd)/config:/app/config --rm --entrypoint=${ENTRYPOINT} ${REGISTRY_NAME}/${IMAGE_NAME}:latest
