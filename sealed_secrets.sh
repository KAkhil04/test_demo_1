#!/bin/bash

# Check if input.txt exists
if [[ ! -f "input.txt" ]]; then
    echo "Error: input.txt file not found"
    exit 1
fi

# Check if image-pull-secret.yaml exists
if [[ ! -f "image-pull-secret.yaml" ]]; then
    echo "Error: image-pull-secret.yaml file not found"
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
    
    # Process the secret (fixed line continuation)
    cat image-pull-secret.yaml | kubeseal \
        --controller-namespace bitnami-sealed-secrets \
        --controller-name bitnami-sealed-secrets \
        --format yaml > sealed-secret.yaml
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to process secret for cluster $clustername"
        continue
    fi
    
    # Apply the sealed secret
    oc apply -f sealed-secret.yaml
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to apply sealed secret to cluster $clustername"
        continue
    fi
    
    echo "Successfully processed cluster: $clustername"
    echo "------------------------------------"
done < "input.txt"

echo "Script execution completed"