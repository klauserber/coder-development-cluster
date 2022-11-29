#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

gcp-get-secret --name ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} > ${SCRIPT_DIR}/config/app_config.yml
