#!/usr/bin/env sh

# on arm64: docker run --privileged --rm tonistiigi/binfmt --install all
# on amd64: docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --name multiarch --driver docker-container --use
# docker buildx inspect --bootstrap

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster

docker buildx build \
  . \
  -t ${REGISTRY_NAME}/${IMAGE_NAME}:${VERSION} \
  -t ${REGISTRY_NAME}/${IMAGE_NAME}:latest \
  --build-arg IMAGE_NAME=${IMAGE_NAME} \
  --platform=linux/arm64,linux/amd64 "${@}"

  # --push \
  # --no-cache --pull \
