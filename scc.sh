#!/bin/bash

# Define the regex for SCCs to exclude
exclude_regex="^privileged$|^hostnetwork-v2$|^restricted-v2$|^nonroot-v2$"

# Get all SCCs
sccs=$(oc get scc -o jsonpath='{.items[*].metadata.name}')

# Initialize an empty report
report=""

# Loop over each SCC
for scc in $sccs; do
  # Check if the SCC should be excluded
  if [[ ! $scc =~ $exclude_regex ]]; then
    # Get the SCC's allowedCapabilities
    capabilities=$(oc get scc $scc -o jsonpath='{.allowedCapabilities}')

    # Add the SCC and its capabilities to the report
    report+="$scc: $capabilities\n"
  fi
done

# Print the report
echo -e $report
