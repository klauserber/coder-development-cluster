#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

CLUSTER_NAME=${1}

if [ -z "${CLUSTER_NAME}" ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

gcp-get-secret --name ${CLUSTER_NAME}_env > ${SCRIPT_DIR}/config/env
gcp-get-secret --name ${CLUSTER_NAME}_app_config > ${SCRIPT_DIR}/config/app_config.yml

echo ok.