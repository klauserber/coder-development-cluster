#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/script_init.inc.sh

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

gcloud secrets delete default_app_config --project ${GCLOUD_PROJECT} --quiet 2> /dev/null || true
gcloud secrets create default_app_config --project ${GCLOUD_PROJECT} --data-file=${SCRIPT_DIR}/config_default/app_config.yml

gcloud secrets delete ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} --quiet 2> /dev/null || true
gcloud secrets create ${CLUSTER_NAME}_app_config --project ${GCLOUD_PROJECT} --data-file=${SCRIPT_DIR}/config/app_config.yml

echo ok.
