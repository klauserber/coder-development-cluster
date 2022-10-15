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

CLUSTER_NAME=${1-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

gcloud auth activate-service-account --key-file=config/google-cloud.json

${SCRIPT_DIR}/secrets_get.sh ${CLUSTER_NAME}

${SCRIPT_DIR}/run_infra.sh
${SCRIPT_DIR}/run_automate.sh

chown_on_exit
