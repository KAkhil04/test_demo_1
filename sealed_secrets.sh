#!/bin/bash

# Check if input.txt exists
if [ ! -f "input.txt" ]; then
    echo "Error: input.txt file not found"
    exit 1
fi

# Read cluster names from input.txt line by line
while IFS= read -r clustername; do
    # Skip empty lines
    [ -z "$clustername" ] && continue
    
    echo "Processing cluster: $clustername"
    
    # Login to OCP cluster
    oc login "https://api.${clustername}.ebiz.xyz.com:6443" -u kurelak
    
    # Check if login was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to login to cluster $clustername"
        continue
    }
    
    # Process the secret
    cat image-pull-secret.yaml | kubeseal \
        --controller-namespace bitnami-sealed-secrets \
        --controller-name bitnami-sealed-secrets \
        --format yaml > sealed-secret.yaml
    
    # Check if kubeseal command was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to process secret for cluster $clustername"
        continue
    }
    
    # Apply the sealed secret
    oc apply -f sealed-secret.yaml
    
    # Check if apply was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to apply sealed secret to cluster $clustername"
        continue
    }
    
    echo "Successfully processed cluster: $clustername"
    echo "------------------------------------"
    
done < "input.txt"

echo "Script execution completed"