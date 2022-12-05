#!/usr/bin/env bash
CLUSTER_NAME=${1}

if [[ -z ${CLUSTER_NAME} ]]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

TARGET_DIR=config
SRC_DIR=config_${CLUSTER_NAME}

if [[ -d ${TARGET_DIR} ]] && [[ ! -L ${TARGET_DIR} ]]; then
  echo "Target '${TARGET_DIR}' already exists and is not a symbolic link. Please move it first."
  exit 1
fi

if [[ ! -d ${SRC_DIR} ]]; then
  echo "Source '${SRC_DIR}' does not exist. Please create one first."
  exit 1
fi

ln -sfn ${SRC_DIR} ${TARGET_DIR}

echo "Linked '${SRC_DIR}' to '${TARGET_DIR}'."