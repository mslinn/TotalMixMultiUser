# Install script for TotalMixFX scripts
# This script sets up the necessary directories and files for TotalMixFX management Scripts
# Mike Slinn 2025-07-26

# Get the full path of the current script
$scriptPath = $MyInvocation.MyCommand.Path

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $scriptPath

$destPath = $env:ProgramData\Scripts\TotalMix

# Ensure the %ProgramData%\Scripts\TotalMix directory exists
New-Item `
  -ItemType Directory `
  -Path $destPath


# Copy all items in the script directory, excluding the script itself
Get-ChildItem -Path $scriptDirectory | `
  Where-Object { $_.FullName -ne $scriptPath } | `
  Copy-Item -Destination $destPath -Recurse -Force

# Ensure the log directory exists
New-Item -ItemType Directory -Path "C:\ProgramData\Scripts" -Force

# Create the log directory if it doesn't exist
$logDirectory = "C:\ProgramData\Scripts"
