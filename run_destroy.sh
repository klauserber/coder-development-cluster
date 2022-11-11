#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

UNINSTALL_APPS=${3:-true}
REMOVE_BACKUPS=${4:-false}


${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

${SCRIPT_DIR}/secrets_get.sh ${GCLOUD_PROJECT} ${CLUSTER_NAME}


ansible-playbook -i inventory ${SCRIPT_DIR}/automate/tf_vars.yml

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

if [[ ! ${UNINSTALL_APPS} == "false" ]]; then
  ${SCRIPT_DIR}/get_kubeconfig.sh
  IP_ADDRESS=$(terraform -chdir=${SCRIPT_DIR}/infrastructure/google output -raw ip_address)
  ansible-playbook -i inventory ${SCRIPT_DIR}/automate/destroy.yml -e ip_address=${IP_ADDRESS}
fi

terraform -chdir=${SCRIPT_DIR}/infrastructure/google destroy -auto-approve

if [[ ${REMOVE_BACKUPS} == "true" ]]; then
  ansible-playbook -i inventory ${SCRIPT_DIR}/automate/remove_backups.yml
fi
