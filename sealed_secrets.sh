#!/bin/bash

# Prompt for registry details
read -p "Enter registry server (e.g., docker.io): " REGISTRY_SERVER
read -p "Enter registry username: " REGISTRY_USERNAME
read -s -p "Enter registry password: " REGISTRY_PASSWORD; echo ""
read -p "Enter registry email (default: default@example.com): " REGISTRY_EMAIL
REGISTRY_EMAIL=${REGISTRY_EMAIL:-"default@example.com"}

# Validate inputs
[[ -z "$REGISTRY_SERVER" || -z "$REGISTRY_USERNAME" || -z "$REGISTRY_PASSWORD" ]] && { echo "Error: Missing required input"; exit 1; }
[[ ! -f "input.txt" ]] && { echo "Error: input.txt not found"; exit 1; }

# Check dependencies
for cmd in oc kubeseal; do
    command -v "$cmd" &>/dev/null || { echo "Error: $cmd not found"; exit 1; }
done

# Process clusters
while IFS= read -r clustername || [[ -n "$clustername" ]]; do
    [[ -z "$clustername" ]] && continue
    echo "Processing cluster: $clustername"

    if ! oc login "https://api.${clustername}.ebiz.xyz.com:6443" -u kurelak --insecure-skip-tls-verify; then
        echo "Error: Failed to login to $clustername"; continue
    fi

    oc delete sealedsecret my-pull-secret --ignore-not-found

    oc create secret docker-registry my-pull-secret \
        --docker-server="$REGISTRY_SERVER" --docker-username="$REGISTRY_USERNAME" \
        --docker-password="$REGISTRY_PASSWORD" --docker-email="$REGISTRY_EMAIL" \
        --dry-run=client -o yaml | kubeseal \
        --controller-namespace bitnami-sealed-secrets --controller-name bitnami-sealed-secrets \
        --format yaml | oc apply -f -

    echo "Successfully processed cluster: $clustername"
done < "input.txt"

echo "Script execution completed"