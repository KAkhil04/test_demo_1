# Base directory
$BASE_DIR = "dedicated"

# Find all YAML files in the specified directory
Get-ChildItem -Path $BASE_DIR -Recurse -Filter *.yaml | ForEach-Object {
    $file = $_.FullName

    # Extract the cluster name from line 20
    $line20 = Get-Content -Path $file | Select-Object -Index 19
    if ($line20 -match 'https:\/\/api\.(.*?)\.ebiz\.verizon\.com') {
        $cluster_name = $matches[1]
    } elseif ($line20 -match 'https:\/\/api\.(.*?)\.verizon\.com') {
        $cluster_name = $matches[1]
    } else {
        $cluster_name = $null
    }

    # If cluster name is found
    if ($cluster_name) {
        # Determine the current vsad directory
        $vsad_dir = Split-Path -Path (Split-Path -Path (Split-Path -Path $file -Parent) -Parent) -Parent

        # Create the new directory structure
        $new_dir = Join-Path -Path $BASE_DIR -ChildPath "$cluster_name"
        New-Item -ItemType Directory -Path $new_dir -Force | Out-Null

        # Copy the entire vsad directory to the new location
        $vsad_name = Split-Path -Leaf $vsad_dir
        Copy-Item -Path $vsad_dir -Destination $new_dir -Recurse -Force

        # Update line 18 in the copied YAML file
        $new_file = Join-Path -Path $new_dir -ChildPath "$vsad_name\app\$(Split-Path -Leaf $file)"
        (Get-Content -Path $new_file) | ForEach-Object {
            if ($_ -match 'path: Dedicated/.*') {
                $_ -replace 'path: Dedicated/.*', "path: Dedicated/$cluster_name/$vsad_name/env"
            } else {
                $_
            }
        } | Set-Content -Path $new_file
    } else {
        Write-Host "Cluster name not found in $file"
    }
}
