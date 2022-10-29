#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json

export KUBECONFIG=${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke

echo get kubeconfig from google with:
echo ""
echo "    gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke"
echo ""
