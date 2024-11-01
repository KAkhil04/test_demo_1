# Define the source and destination base directories
$sourceBaseDir = "dedicated"
$destBaseDir = "dedicated"

# Function to read the cluster name from the YAML file
function Get-ClusterNameFromYaml {
    param (
        [string]$filePath
    )
    $line = Get-Content -Path $filePath | Select-Object -Index 19
    if ($line -match "https://api\.([^.]+)\.") {
        return $matches[1]
    }
    return $null
}

# Function to move and update the YAML file
function MoveAndModifyYamlFile {
    param (
        [string]$sourceFilePath,
        [string]$destFilePath,
        [string]$clusterName
    )
    # Create the destination directory if it doesn't exist
    $destDir = Split-Path -Path $destFilePath -Parent
    if (-not (Test-Path -Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force
    }

    # Read the content of the YAML file
    $content = Get-Content -Path $sourceFilePath

    # Update the cluster name in line 20
    $content[19] = $content[19] -replace "https://api\.[^.]+\.", "https://api.$clusterName."

    # Write the updated content to the new file
    $content | Set-Content -Path $destFilePath

    # Remove the original file
    Remove-Item -Path $sourceFilePath
}

# Process each YAML file in the source directory
Get-ChildItem -Path $sourceBaseDir -Recurse -Filter *.yaml | ForEach-Object {
    $sourceFilePath = $_.FullName
    $clusterName = Get-ClusterNameFromYaml -filePath $sourceFilePath

    if ($clusterName) {
        # Construct the destination file path
        $relativePath = $sourceFilePath.Substring((Get-Location).Path.Length + 1)
        $destFilePath = Join-Path -Path $destBaseDir -ChildPath $relativePath
        $destFilePath = $destFilePath -replace "^[^\\]+", $clusterName

        # Move and modify the YAML file
        MoveAndModifyYamlFile -sourceFilePath $sourceFilePath -destFilePath $destFilePath -clusterName $clusterName

        # Move the entire vsad directory to the new cluster directory
        $vsadDir = Split-Path -Path $sourceFilePath -Parent -Parent
        $newVsadDir = Join-Path -Path $destBaseDir -ChildPath "$clusterName\$($vsadDir.Substring($sourceBaseDir.Length + 1))"
        if (-not (Test-Path -Path $newVsadDir)) {
            Move-Item -Path $vsadDir -Destination $newVsadDir
        }
    }
}
