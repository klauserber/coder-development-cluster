#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function chown_on_exit() {
  echo "exit"
  local USERID=$(stat -c '%u' config)
  local GROUPID=$(stat -c '%g' config)
  chown -R ${USERID}:${GROUPID} config
}

trap chown_on_exit ERR INT

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

${SCRIPT_DIR}/secrets_get.sh ${GCLOUD_PROJECT} ${CLUSTER_NAME}

${SCRIPT_DIR}/run_infra.sh
${SCRIPT_DIR}/run_automate.sh

chown_on_exit
