#!/bin/bash

# Check for required environment variables
if [[ -z "$REGISTRY_SERVER" || -z "$REGISTRY_USERNAME" || -z "$REGISTRY_PASSWORD" ]]; then
    echo "Error: Please set REGISTRY_SERVER, REGISTRY_USERNAME, and REGISTRY_PASSWORD environment variables"
    exit 1
fi

# Optional email, can be empty
REGISTRY_EMAIL=${REGISTRY_EMAIL:-"default@example.com"}

# Check if input.txt exists
if [[ ! -f "input.txt" ]]; then
    echo "Error: input.txt file not found"
    exit 1
fi

# Check for required commands
for cmd in oc kubeseal; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed or not in PATH"
        exit 1
    fi
done

# Read cluster names from input.txt
while IFS= read -r clustername || [[ -n "$clustername" ]]; do
    # Skip empty lines
    [[ -z "$clustername" ]] && continue
    
    echo "Processing cluster: $clustername"
    
    # Login to OCP cluster
    oc login "https://api.${clustername}.ebiz.xyz.com:6443" -u kurelak --insecure-skip-tls-verify
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to login to cluster $clustername"
        continue
    fi
    
    # Create the image pull secret
    oc create secret docker-registry my-pull-secret \
        --docker-server="$REGISTRY_SERVER" \
        --docker-username="$REGISTRY_USERNAME" \
        --docker-password="$REGISTRY_PASSWORD" \
        --docker-email="$REGISTRY_EMAIL" \
        --dry-run=client -o yaml > image-pull-secret.yaml
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create image pull secret for cluster $clustername"
        continue
    fi
    
    # Seal the secret
    cat image-pull-secret.yaml | kubeseal \
        --controller-namespace bitnami-sealed-secrets \
        --controller-name bitnami-sealed-secrets \
        --format yaml > sealed-secret.yaml
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to seal secret for cluster $clustername"
        continue
    fi
    
    # Apply the sealed secret
    oc apply -f sealed-secret.yaml
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to apply sealed secret to cluster $clustername"
        continue
    fi
    
    # Clean up temporary files
    rm -f image-pull-secret.yaml sealed-secret.yaml
    
    echo "Successfully processed cluster: $clustername"
    echo "------------------------------------"
done < "input.txt"

echo "Script execution completed"