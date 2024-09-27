#!/bin/bash

# Log in to the OpenShift cluster
oc login <API_URL> --token=<TOKEN>

# Get the list of all namespaces
namespaces=$(oc get namespaces -o jsonpath='{.items[*].metadata.name}')

# Iterate over each namespace to find installed operators
for namespace in $namespaces; do
  echo "Checking namespace: $namespace"
  
  # Get the list of ClusterServiceVersions (CSVs) in the namespace
  csvs=$(oc get csv -n $namespace -o jsonpath='{.items[*].metadata.name}')
  
  for csv in $csvs; do
    # Get the current version of the operator
    current_version=$(oc get csv $csv -n $namespace -o jsonpath='{.spec.version}')
    
    # Get the operator name from the CSV name
    operator_name=$(oc get csv $csv -n $namespace -o jsonpath='{.spec.displayName}')
    
    # Get the available stable version of the operator
    stable_version=$(oc get packagemanifest $operator_name -o jsonpath='{.status.channels[?(@.name=="stable")].currentCSVDesc.version}')
    
    # Print the current and stable versions
    echo "Operator: $operator_name"
    echo "Current Version: $current_version"
    echo "Stable Version: $stable_version"
    echo "-----------------------------------"
  done
done
