#!/usr/bin/env bash

NODE="$1"
NEW_IMAGE="$2"
ROLLOUT="${3:-false}"

# get the current machine image
FROM_VERSION=$(kubectl get node "${NODE}" --output jsonpath='{.metadata.labels.feature\.node\.kubernetes\.io/system-os_release\.VERSION_ID}')
echo "Current Image: ${FROM_VERSION}"

NEW_VERSION=${NEW_IMAGE##*:}
echo "New Image: ${NEW_VERSION}"

echo "Checking if Talos needs to be upgraded on node '${NODE}' ..."
if [ "${FROM_VERSION}" == "${NEW_VERSION}" ]; then
    echo "Talos is already up to date on version '${FROM_VERSION}', skipping upgrade ..."
    exit 0
fi

echo "Upgrade required"

echo "Waiting for all jobs to complete before upgrading Talos on node '${NODE}' ..."
until kubectl wait --timeout=5m --for=condition=Complete jobs --all --all-namespaces; do
    echo "Waiting for all jobs to complete before upgrading Talos on node '${NODE}' ..."
    sleep 10
done

if [ "$ROLLOUT" != "true" ]; then
    echo "Suspending Flux Kustomizations ..."
    flux suspend kustomization --all
    echo "Setting CNPG maintenance mode ..."
    kubectl cnpg maintenance set --reusePVC --all-namespaces
fi

echo "Upgrading Talos on node '${NODE}' to ${NEW_VERSION}..."
talosctl --nodes "${NODE}" upgrade --image "${NEW_IMAGE}" --wait=true --timeout=10m --preserve=true

echo "Waiting for Talos to be healthy on node '${NODE}' ..."
talosctl --nodes "$NODE" health --wait-timeout=10m --server=false

echo "Waiting for Ceph health to be OK on node '${NODE}' ..."
until kubectl wait --timeout=5m --for=jsonpath=.status.ceph.health=HEALTH_OK cephcluster --all --all-namespaces; do
    echo "Waiting for Ceph health to be OK on node '${NODE}' ..."
    sleep 10
done

if [ "$ROLLOUT" != "true" ]; then
    echo "Resuming Flux Kustomizations ..."
    flux resume kustomization --all
    echo "Unsetting CNPG maintenance mode ..."
    kubectl cnpg maintenance unset --reusePVC --all-namespaces
fi
