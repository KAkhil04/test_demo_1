#!/bin/bash

read -p "Enter registry server: " REGISTRY_SERVER
read -p "Enter registry username: " REGISTRY_USERNAME
read -s -p "Enter registry password: " REGISTRY_PASSWORD; echo ""
read -p "Enter registry email (default: default@example.com): " REGISTRY_EMAIL
REGISTRY_EMAIL=${REGISTRY_EMAIL:-"default@example.com"}

[[ -z "$REGISTRY_SERVER" || -z "$REGISTRY_USERNAME" || -z "$REGISTRY_PASSWORD" || ! -f "input.txt" ]] && { echo "Error: Missing input or input.txt not found"; exit 1; }
for cmd in oc kubeseal; do command -v "$cmd" &>/dev/null || { echo "Error: $cmd not found"; exit 1; }; done

while IFS= read -r clustername || [[ -n "$clustername" ]]; do
    [[ -z "$clustername" ]] && continue
    echo "Processing: $clustername"
    oc login "https://api.${clustername}.ebiz.xyz.com:6443" -u kurelak --insecure-skip-tls-verify || { echo "Login failed"; continue; }
    oc delete sealedsecret my-pull-secret --ignore-not-found
    oc create secret docker-registry my-pull-secret --docker-server="$REGISTRY_SERVER" --docker-username="$REGISTRY_USERNAME" --docker-password="$REGISTRY_PASSWORD" --docker-email="$REGISTRY_EMAIL" --dry-run=client -o yaml | \
    kubeseal --controller-namespace bitnami-sealed-secrets --controller-name bitnami-sealed-secrets --format yaml | oc apply -f - && echo "Success: $clustername"
done < "input.txt"

echo "Done."