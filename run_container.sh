#!/usr/bin/env bash

REGISTRY_NAME=isi006
IMAGE_NAME=coder-development-cluster

COMMAND=${1}

if [[ ! ${COMMAND} =~ ^(run_create|run_destroy|secrets_get|secrets_create|secrets_delete|get_kubeconfig)$ ]]; then
  echo "Usage: $0 COMMAND [google-project-name] [cluster-name]"
  echo ""
  echo "  COMMANDS:"
  echo "    run_create - create a cluster"
  echo "    run_destroy - create a cluster"
  echo "    secrets_get - get the secrets from the google secret of a cluster"
  echo "    secrets_create - write the secrets to the google secret of a cluster"
  echo "    secrets_delete - delete the google secret of a cluster"
  echo "    get_kubeconfig - get the kubeconfig of a cluster"
  echo ""
  exit 1
fi

docker run -it \
  -v $(pwd)/config:/app/config \
  --rm \
  --entrypoint=/app/${COMMAND}.sh \
  ${REGISTRY_NAME}/${IMAGE_NAME}:latest ${@:2}
