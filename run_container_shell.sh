#!/usr/bin/env bash

. VERSION

# echo "pull image ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG}"
# docker pull ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} > /dev/null

docker run -it \
  -v $(pwd)/config_default:/app/config_default \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=bash \
  ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} ${@}
