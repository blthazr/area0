#!/usr/bin/env bash

JOB=$1
NAMESPACE="${2:-default}"

[[ -z "${JOB}" ]] && echo "Job name not specified" && exit 1


JOB_LABEL_FILTER="app.kubernetes.io/created-by=volsync"
OWNER_REFERENCE=".name=${JOB}"

# get job owned by replication destination
while true; do
    REPLICATION_DESTINATION_JOB_NAME=$(kubectl get job -l "${JOB_LABEL_FILTER}" -n "${NAMESPACE}" -o json | jq -r '.items[0] | select(.metadata.ownerReferences[] | select("${OWNER_REFERENCE}")) | .metadata.name')
    if [ ! -z "${REPLICATION_DESTINATION_JOB_NAME}" ]; then
        break
    fi
    sleep 1
done

# wait for the job to become active
while true; do
    STATUS="$(kubectl -n ${NAMESPACE} get job ${REPLICATION_DESTINATION_JOB_NAME} -o jsonpath='{.status.active}')"
    if [ "${STATUS}" == "1" ]; then
        break
    fi
    sleep 1
done

# wait for the replication destination to be successful
while true; do
    STATUS="$(kubectl -n ${NAMESPACE} get ReplicationDestination ${JOB} -o jsonpath='{.status.latestMoverStatus.result}')"
    if [ "${STATUS}" == "Successful" ]; then
        break
    fi
    sleep 1
done
