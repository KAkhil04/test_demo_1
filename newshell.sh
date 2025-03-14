#!/bin/bash

# Define the base directory
BASE_DIR="Dedicated"

# Loop through each vsad directory
for vsad_dir in "$BASE_DIR"/*; do
  # Skip if it's not a directory or if it's the argoApps directory
  if [[ ! -d "$vsad_dir" || "$(basename "$vsad_dir")" == "argoApps" ]]; then
    echo "Skipping $(basename "$vsad_dir")"
    continue
  fi

  echo "Processing $(basename "$vsad_dir")"

  # Loop through each subdirectory in the vsad directory
  for sub_dir in "$vsad_dir"/*; do
    # Skip if it's not a directory
    if [[ ! -d "$sub_dir" ]]; then
      continue
    fi

    echo "Checking subdirectory $(basename "$sub_dir")"

    # Find the Argo Application yaml file in the subdirectory
    yaml_file=$(find "$sub_dir" -maxdepth 1 -name "*.yaml" | head -n 1)
    
    # If no yaml file is found, skip this subdirectory
    if [[ -z "$yaml_file" ]]; then
      echo "No yaml file found in $(basename "$sub_dir")"
      continue
    fi

    echo "Found yaml file: $yaml_file"

    # Extract the cluster name from the yaml file
    cluster_name=$(grep -oP 'api\.\K[^.]+' "$yaml_file")

    # If no cluster name is found, skip this subdirectory
    if [[ -z "$cluster_name" ]]; then
      echo "No cluster name found in $yaml_file"
      continue
    fi

    echo "Cluster name: $cluster_name"

    # Create the cluster directory if it doesn't exist
    cluster_dir="$BASE_DIR/$cluster_name"
    mkdir -p "$cluster_dir"

    # Move the vsad directory to the cluster directory
    mv "$vsad_dir" "$cluster_dir"
    echo "Moved $(basename "$vsad_dir") to $cluster_dir"

    # Break the loop as we have already moved the vsad directory
    break
  done
done
