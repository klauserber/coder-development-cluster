#!/usr/bin/env bash
set -e

PLAYBOOK=${1:-deploy.yml}
if [[ $# > 0 ]]; then
  shift
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/config/env

IP_ADDRESS=$(terraform -chdir=${SCRIPT_DIR}/infrastructure/google output -raw ip_address)

cd ${SCRIPT_DIR}/automate
ansible-playbook -i inventory \
  -e "cluster_name=${CLUSTER_NAME}" \
  -e "domain_name=${DOMAIN_NAME}" \
  -e "ip_address=${IP_ADDRESS}" \
  -e "bucket_name=${BUCKET_NAME}" \
  ${PLAYBOOK} "${@}"
