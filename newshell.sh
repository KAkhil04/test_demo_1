#!/bin/bash

# Define the base directory
BASE_DIR="Dedicated"

# Loop through each vsad directory
for vsad_dir in "$BASE_DIR"/*; do
  # Skip if it's not a directory or if it's the argoApps directory
  if [[ ! -d "$vsad_dir" || "$(basename "$vsad_dir")" == "argoApps" ]]; then
    continue
  fi

  # Find the Argo Application yaml file in the vsad directory
  yaml_file=$(find "$vsad_dir" -maxdepth 1 -name "*.yaml" | head -n 1)
  
  # If no yaml file is found, skip this vsad directory
  if [[ -z "$yaml_file" ]]; then
    continue
  fi

  # Extract the cluster name from the yaml file
  cluster_name=$(grep -oP 'api\.\K[^.]+' "$yaml_file")

  # If no cluster name is found, skip this vsad directory
  if [[ -z "$cluster_name" ]]; then
    continue
  fi

  # Create the cluster directory if it doesn't exist
  cluster_dir="$BASE_DIR/$cluster_name"
  mkdir -p "$cluster_dir"

  # Move the vsad directory to the cluster directory
  mv "$vsad_dir" "$cluster_dir"
done
