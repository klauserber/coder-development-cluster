#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function chown_on_exit() {
  echo "exit"
  local USERID=$(stat -c '%u' config)
  local GROUPID=$(stat -c '%g' config)
  chown -R ${USERID}:${GROUPID} config
  chown -R ${USERID}:${GROUPID} ${HOME}/.config/gcloud
}

trap chown_on_exit ERR INT

GCLOUD_LOGIN=${1:-true}

if [ -z ${GCLOUD_LOGIN} ]; then
  echo "Usage: $0 <GCLOUD_LOGIN:true|false>"
  exit 1
fi

if [ "${GCLOUD_LOGIN}" == "true" ]; then
  gcloud auth login
fi

ansible-playbook ${SCRIPT_DIR}/automate/bootstrap_google_project.yml

chown_on_exit
