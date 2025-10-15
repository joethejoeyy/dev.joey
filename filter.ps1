# Run this from the folder you’re in
$src = Get-Location
$dst = "$src\filtered"

# Create the destination folder
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# Copy only .txt and .json files while preserving folder structure
Get-ChildItem -Path $src -Recurse -Include *.txt, *.json | ForEach-Object {
    $target = Join-Path $dst ($_.FullName.Substring($src.Path.Length + 1))
    $targetDir = Split-Path $target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }
    Copy-Item $_.FullName -Destination $target -Force
}
