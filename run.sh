#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

# -auto-approve

# terraform -chdir=${SCRIPT_DIR}/infrastructure/google apply \
#   -var "project_id=${PROJECT_ID}" \
#   -var "region=${REGION}" \
#   -var "cluster_location=${CLUSTER_LOCATION}" \
#   -var "system_name=${CLUSTER_NAME}" \
#   -var "managed_zone=${MANAGED_ZONE}" \
#   -var "domain_name=${DOMAIN_NAME}" \

IP_ADDRESS=$(terraform -chdir=${SCRIPT_DIR}/infrastructure/google output -raw ip_address)

# gcloud auth activate-service-account --project=${PROJECT_ID} --key-file=config/google-cloud.json
# export KUBECONFIG=${SCRIPT_DIR}/config/${CLUSTER_NAME}_kubeconfig
# gcloud container clusters get-credentials --zone ${CLUSTER_LOCATION} --project ${PROJECT_ID} ${CLUSTER_NAME}-gke

cd ${SCRIPT_DIR}/automate
ansible-playbook -i inventory \
  -e "cluster_name=${CLUSTER_NAME}" \
  -e "domain_name=${DOMAIN_NAME}" \
  -e "ip_address=${IP_ADDRESS}" \
  deploy.yml
