#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

CLUSTER_NAME=${1-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

gcloud auth activate-service-account --key-file=config/google-cloud.json

${SCRIPT_DIR}/secrets_get.sh ${CLUSTER_NAME}

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init -auto-approve \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

terraform -chdir=${SCRIPT_DIR}/infrastructure/google destroy