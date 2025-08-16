REGISTRY_NAME ?= isi006
IMAGE_NAME ?= coder-devcontainer:1.0.0

.PHONY: build build-multi

build:
	docker build . -t $(REGISTRY_NAME)/$(IMAGE_NAME)

build-multi:
	docker buildx build . \
	  -t $(REGISTRY_NAME)/$(IMAGE_NAME) \
	  --push \
	  --platform=linux/arm64,linux/amd64
