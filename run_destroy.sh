#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}
UNINSTALL_APPS=${3:-true}

if [ -z "${CLUSTER_NAME}" ] || [ -z "${GCLOUD_PROJECT}" ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <CLUSTER_NAME> [UNINSTALL_APPS 'true' or 'false' default 'true']"
  exit 1
fi

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

${SCRIPT_DIR}/secrets_get.sh ${CLUSTER_NAME}


ansible-playbook -i inventory ${SCRIPT_DIR}/automate/tf_vars.yml

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json


if [[ ! ${UNINSTALL_APPS} == "false" ]]; then
  ${SCRIPT_DIR}/get_kubeconfig.sh
  ansible-playbook -i inventory ${SCRIPT_DIR}/automate/destroy.yml
fi

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

terraform -chdir=${SCRIPT_DIR}/infrastructure/google destroy -auto-approve