#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function chown_on_exit() {
  echo "exit"
  local USERID=$(stat -c '%u' config)
  local GROUPID=$(stat -c '%g' config)
  chown -R ${USERID}:${GROUPID} config
}

trap chown_on_exit ERR INT

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ] || [ -z "${GCLOUD_PROJECT}" ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <CLUSTER_NAME>"
  exit 1
fi

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

${SCRIPT_DIR}/secrets_get.sh ${CLUSTER_NAME}

${SCRIPT_DIR}/run_infra.sh
${SCRIPT_DIR}/run_automate.sh

chown_on_exit
