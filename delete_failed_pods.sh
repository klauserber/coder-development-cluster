#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

kubectl --kubeconfig ${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig delete po --field-selector status.phase=Failed -A