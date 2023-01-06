#!/usr/bin/env bash
set -e

PLAYBOOK=${1:-deploy.yml}
if [[ $# > 0 ]]; then
  shift
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-coder-automation.json

IP_ADDRESS=$(terraform -chdir=${SCRIPT_DIR}/infrastructure/google output -raw ip_address)

cd ${SCRIPT_DIR}/automate
ansible-playbook -i inventory ${PLAYBOOK} -e ip_address=${IP_ADDRESS} "${@}"
