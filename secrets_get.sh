#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ] || [ -z ${GCLOUD_PROJECT} ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <cluster-name>"
  exit 1
fi

gcp-get-secret --name ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} > ${SCRIPT_DIR}/config/app_config.yml
