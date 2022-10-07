#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${STORAGE_BUCKET}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

# -auto-approve

terraform -chdir=${SCRIPT_DIR}/infrastructure/google destroy