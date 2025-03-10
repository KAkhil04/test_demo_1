#!/bin/bash

# Define the source and destination base directories
sourceBaseDir="dedicated"
destBaseDir="dedicated"
argoAppsSourceDir="Dedicated/argoApps"

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

# Function to copy folders under vsad directories
copyVsadFolders() {
    local sourceVsadDir="$1"
    local destVsadDir="$2"

    # Copy all folders and files from source vsad directory to destination vsad directory
    cp -r "$sourceVsadDir"/* "$destVsadDir"
}

# Function to copy the appropriate YAML file to the argoApps folder
copyArgoAppsYaml() {
    local vsad="$1"
    local app="$2"
    local clusterName="$3"
    local destArgoAppsDir="$4"

    local sourceYamlFile="$argoAppsSourceDir/$vsad-$app-nonprod-Dedicated.yaml"
    local destYamlFile="$destArgoAppsDir/$vsad-$app-nonprod-Dedicated.yaml"

    if [[ -f $sourceYamlFile ]]; then
        echo "Copying $sourceYamlFile to $destYamlFile"
        cp "$sourceYamlFile" "$destYamlFile"
    else
        echo "Source YAML file $sourceYamlFile not found"
    fi
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
            mkdir -p "$(dirname "$newVsadDir")"
            mv "$vsadDir" "$(dirname "$newVsadDir")"
        fi

        # Copy folders under vsad directories
        copyVsadFolders "$vsadDir" "$newVsadDir"

        # Create the argoApps folder inside the cluster folder
        argoAppsDir="$destBaseDir/$clusterName/argoApps"
        if [[ ! -d $argoAppsDir ]]; then
            echo "Creating argoApps directory: $argoAppsDir"
            mkdir -p "$argoAppsDir"
        fi

        # Extract vsad and app from the directory structure
        vsad=$(basename "$(dirname "$sourceFilePath")")
        app=$(basename "$(dirname "$(dirname "$sourceFilePath")")")

        # Copy the appropriate YAML file to the argoApps folder
        copyArgoAppsYaml "$vsad" "$app" "$clusterName" "$argoAppsDir"
    else
        echo "Cluster name not found in file: $sourceFilePath"
    fi
done
