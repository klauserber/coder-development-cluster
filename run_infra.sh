#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

terraform -chdir=${SCRIPT_DIR}/infrastructure/${INFRASTRUCTURE_PROVIDER} apply -auto-approve \
  -var "project_id=${PROJECT_ID}" \
  -var "region=${REGION}" \
  -var "cluster_location=${CLUSTER_LOCATION}" \
  -var "system_name=${CLUSTER_NAME}" \
  -var "managed_zone=${MANAGED_ZONE}" \
  -var "domain_name=${DOMAIN_NAME}" \
  -var "machine_type=${MACHINE_TYPE}" \
  -var "min_node_count=${MIN_NODE_COUNT}" \
  -var "max_node_count=${MAX_NODE_COUNT}" \
  -var "preemptible=${PREEMPTIBLE}"

export KUBECONFIG=${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke
