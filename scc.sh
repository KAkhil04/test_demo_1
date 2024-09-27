#!/bin/bash

# Log in to the OpenShift cluster
# oc login <API_URL> --token=<TOKEN>

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
    
    # Get the available upgradable version of the operator
    upgradable_version=$(oc get csv $csv -n $namespace -o jsonpath='{.status.replaces}')
    
    # Print the current and upgradable versions
    echo "Operator: $csv"
    echo "Current Version: $current_version"
    echo "Upgradable Version: $upgradable_version"
    echo "-----------------------------------"
  done
done
