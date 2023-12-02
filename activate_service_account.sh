#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}

if [ -z "${GCLOUD_PROJECT}" ]; then
  echo "Usage: $0 <GCLOUD_PROJECT>"
  exit 1
fi

gcloud auth activate-service-account --project ${GCLOUD_PROJECT} --key-file=${SCRIPT_DIR}/config_default/google-coder-automation.json
