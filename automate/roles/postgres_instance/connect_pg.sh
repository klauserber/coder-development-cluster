#!/usr/bin/env bash

NS=${1}
TEAM_ID=${2}
INSTANCE=${3}
PORT=${4:-5432}

if [[ -z ${INSTANCE} ]]; then
    echo "      USAGE: ./pg_connect.sh <namespace> <instance-name> <team_id> [port]"
    exit -1
fi

PGMASTER=$(kubectl -n ${NS} get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=${TEAM_ID}-${INSTANCE},spilo-role=master)

PASSWORD=$(kubectl -n ${NS} get secret postgres.${TEAM_ID}-${INSTANCE}.credentials.postgresql.acid.zalan.do -o 'jsonpath={.data.password}' | base64 -d)

echo "port forward the postgres port with:
namespace:              ${NS}
instance name:          ${INSTANCE}
team_id:                ${TEAM_ID}
localhost port:         ${PORT}
pg master pod:          ${PGMASTER}
passwort postgres user: ${PASSWORD}

connect to the database instance by using your favorite database tool like this:

psql -h localhost -U postgres -p ${PORT}
"



kubectl port-forward ${PGMASTER} ${PORT}:5432 -n ${NS}

