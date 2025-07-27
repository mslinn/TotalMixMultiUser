# Install script for TotalMixFX scripts
# Set up the necessary directories and files for TotalMix FX management scripts
# Mike Slinn 2025-07-26

# Get the full path of the current script
$scriptPath = $MyInvocation.MyCommand.Path

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $scriptPath

$destPath = $env:ProgramData\Scripts\totalmix_multiuser

# Ensure the %ProgramData%\Scripts\TotalMix directory exists
New-Item `
  -ItemType Directory `
  -Path $destPath

# Copy all items in the script directory, excluding this script
Get-ChildItem -Path $scriptDirectory | `
  Where-Object { $_.FullName -ne $scriptPath } | `
  Copy-Item -Destination $destPath -Force


# Add "Change" and "Write" rights to the log directory for local users

# Create the log directory if it doesn't exist
$logDirectory = "$($destPath)\Logs"
if (-not (Test-Path -Path $logDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $logDirectory
    Write-Host "Folder '$logDirectory' created successfully."
} else {
    Write-Host "Folder '$logDirectory' already exists."
}

# Get the current ACL of the log directory
$acl = Get-Acl -Path $logDirectory

# Define the identity (local Users group) and the access rights
$identity = "BUILTIN\Users"
$fileSystemRights = `
  [System.Security.AccessControl.FileSystemRights]::Write, `
  [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles

# Create a new FileSystemAccessRule
# AccessControlType::Allow grants the specified rights
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $identity,
    $fileSystemRights,
    [System.Security.AccessControl.AccessControlType]::Allow
)

# Add the new access rule to the ACL
$acl.AddAccessRule($accessRule)

# Apply the modified ACL to the file
Set-Acl -Path $logDirectory -AclObject $acl

Write-Host "Installation complete. Please restart your computer to apply the changes."
