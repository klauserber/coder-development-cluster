set -e

if [ -f ${SCRIPT_DIR}/config/env ]; then
  . ${SCRIPT_DIR}/config/env
fi

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}

if [ -z "${CLUSTER_NAME}" ] || [ -z ${GCLOUD_PROJECT} ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <cluster-name>"
  exit 1
fi
