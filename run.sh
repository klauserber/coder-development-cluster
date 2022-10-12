#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function chown_on_exit() {
  echo "exit"
  local USERID=$(stat -c '%u' config)
  local GROUPID=$(stat -c '%g' config)
  chown -R ${USERID}:${GROUPID} config
}

trap chown_on_exit ERR INT

${SCRIPT_DIR}/run_infra.sh
${SCRIPT_DIR}/run_automate.sh

chown_on_exit
