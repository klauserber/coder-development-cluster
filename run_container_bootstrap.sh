#!/usr/bin/env bash

. VERSION

echo "pull image ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG}"
docker pull ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} > /dev/null

COMMAND=run_bootstrap

docker run -it \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=/app/${COMMAND}.sh \
  ${REGISTRY_NAME}/${IMAGE_NAME}:${TAG} ${@}
