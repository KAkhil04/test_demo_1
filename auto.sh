#!/bin/bash

# Define the source and destination base directories
sourceBaseDir="dedicated"
destBaseDir="dedicated"

# Function to read the cluster name from the YAML file
getClusterNameFromYaml() {
    local filePath="$1"
    local line=$(sed -n '20p' "$filePath")
    if [[ $line =~ https://api\.([^.]+)\. ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Function to move and update the YAML file
moveAndModifyYamlFile() {
    local sourceFilePath="$1"
    local destFilePath="$2"
    local clusterName="$3"

    # Create the destination directory if it doesn't exist
    local destDir
    destDir=$(dirname "$destFilePath")
    mkdir -p "$destDir"

    # Read the content of the YAML file
    local content
    content=$(<"$sourceFilePath")

    # Update the cluster name in line 20
    local updatedContent
    updatedContent=$(echo "$content" | sed "20s|https://api\.[^.]\+\.|https://api.$clusterName.|")

    # Write the updated content to the new file
    echo "$updatedContent" > "$destFilePath"

    # Remove the original file
    rm "$sourceFilePath"
}

# Process each YAML file in the source directory
find "$sourceBaseDir" -type f -name "*.yaml" | while read -r sourceFilePath; do
    clusterName=$(getClusterNameFromYaml "$sourceFilePath")

    if [[ -n $clusterName ]]; then
        echo "Found cluster name: $clusterName in file: $sourceFilePath"

        # Construct the destination file path
        relativePath="${sourceFilePath#$sourceBaseDir/}"
        destFilePath="$destBaseDir/$clusterName/$relativePath"

        # Move and modify the YAML file
        moveAndModifyYamlFile "$sourceFilePath" "$destFilePath" "$clusterName"

        # Move the entire vsad directory to the new cluster directory
        vsadDir=$(dirname "$(dirname "$sourceFilePath")")
        newVsadDir="$destBaseDir/$clusterName/${vsadDir#$sourceBaseDir/}"
        if [[ ! -d $newVsadDir ]]; then
            echo "Moving directory: $vsadDir to $newVsadDir"
            mv "$vsadDir" "$newVsadDir"
        fi
    else
        echo "Cluster name not found in file: $sourceFilePath"
    fi
done
