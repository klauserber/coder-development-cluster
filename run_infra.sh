#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

# -auto-approve

terraform -chdir=${SCRIPT_DIR}/infrastructure/${INFRASTRUCTURE_PROVIDER} apply \
  -var "project_id=${PROJECT_ID}" \
  -var "region=${REGION}" \
  -var "cluster_location=${CLUSTER_LOCATION}" \
  -var "system_name=${CLUSTER_NAME}" \
  -var "managed_zone=${MANAGED_ZONE}" \
  -var "domain_name=${DOMAIN_NAME}" \
  -var "preemptible=${PREEMPTIBLE}"

gcloud auth activate-service-account --project=${PROJECT_ID} --key-file=config/google-cloud.json
export KUBECONFIG=${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke
