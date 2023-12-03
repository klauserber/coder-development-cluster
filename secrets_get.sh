#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

mkdir -p ${SCRIPT_DIR}/config ${SCRIPT_DIR}/config_default

gcp-get-secret --name default_app_config --project ${GCLOUD_PROJECT} > ${SCRIPT_DIR}/config_default/app_config.yml
gcp-get-secret --name ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} > ${SCRIPT_DIR}/config/app_config.yml
