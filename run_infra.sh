#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ansible-playbook -i inventory ${SCRIPT_DIR}/automate/tf_vars.yml

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-coder-automation.json

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

terraform -chdir=${SCRIPT_DIR}/infrastructure/${INFRASTRUCTURE_PROVIDER} apply ${TERRAFORM_OPTIONS} \
  -var-file="${SCRIPT_DIR}/config/variables.tfvars" \

${SCRIPT_DIR}/get_kubeconfig.sh
