#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ] || [ -z ${GCLOUD_PROJECT} ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <cluster-name>"
  exit 1
fi

gcloud secrets delete ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} --quiet 2> /dev/null || true
gcloud secrets create ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} --data-file=${SCRIPT_DIR}/config/app_config.yml

echo ok.