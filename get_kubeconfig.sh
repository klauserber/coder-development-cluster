#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}
export KUBECONFIG=${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig
gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke
