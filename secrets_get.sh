#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

mkdir -p ${SCRIPT_DIR}/config ${SCRIPT_DIR}/config_default

gcloud secrets versions access latest --secret=default_app_config --out-file=${SCRIPT_DIR}/config_default/app_config.yml --project=${GCLOUD_PROJECT}
gcloud secrets versions access latest --secret=${CLUSTER_NAME}_app_config --out-file=${SCRIPT_DIR}/config/app_config.yml --project=${GCLOUD_PROJECT}
