# Install script for TotalMixFX scripts
# Set up the necessary directories, files and tasks for TotalMix FX management scripts
#
# This PowerShell script creates two scheduled tasks:
# TotalMixFX MultiUser Start and TotalMixFX MultiUser Terminate.
#
# Assumptions:
# - This script is run with administrative privileges.
# - The paths and PowerShell scripts (StartTotalMixFX.ps1 and TerminateTotalMixFX.ps1) exist at
#   %ProgramData%\Scripts\TotalMixMultiUser.
#
# Mike Slinn 2025-07-26

function Register-TotalMixTask {
    param (
      [string]$TaskName,
      [string]$Description,
      [string]$ScriptName,
      [string]$UserId,
      [string]$GroupId,
      [ValidateSet("LeastPrivilege", "Highest")]
      [string]$RunLevel,
      [array]$SessionStates,
      [int]$LogonDelaySeconds = 0
    )

    $Action = New-ScheduledTaskAction `
      -Execute "powershell.exe" `
      -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptFolder\$ScriptName`"" `
      -WorkingDirectory $ScriptFolder

    # Create triggers
    $triggers = @()
    $logonTrigger = New-ScheduledTaskTrigger -AtLogOn
    if ($LogonDelaySeconds -gt 0) {
      $logonTrigger.Delay = "PT${LogonDelaySeconds}S"
    }
    $triggers += $logonTrigger

    foreach ($state in $SessionStates) {
      $triggers += New-ScheduledTaskTrigger -AtSessionStateChange -SessionState $state
    }

    # Define principal
    if ($UserId) {
      $principal = New-ScheduledTaskPrincipal -UserId $UserId -RunLevel $RunLevel
    } elseif ($GroupId) {
      $principal = New-ScheduledTaskPrincipal -GroupId $GroupId -RunLevel $RunLevel
    }

    # Settings
    $idle = New-ScheduledTaskIdleSettings -StopOnIdleEnd -RestartOnIdle:$false

    $settings = New-ScheduledTaskSettingsSet `
      -AllowStartIfOnBatteries `
      -StopIfGoingOnBatteries `
      -AllowHardTerminate:$false `
      -StartWhenAvailable `
      -RunOnlyIfNetworkAvailable:$false `
      -AllowStartOnDemand `
      -Enabled `
      -Hidden:$false `
      -RunOnlyIfIdle:$false `
      -DisallowStartOnRemoteAppSession:$false `
      -UseUnifiedSchedulingEngine `
      -ExecutionTimeLimit (New-TimeSpan -Seconds 0) `
      -MultipleInstances IgnoreNew `
      -Priority 7

    $settings.IdleSettings = $idle

    Register-ScheduledTask -TaskName $TaskName `
      -TaskPath "\$scriptDirectory\" `
      -Action $Action `
      -Trigger $triggers `
      -Principal $principal `
      -Settings $settings `
      -Description $Description
}

function InitializeTotalMixLogDirectory {
    param (
      [string]$LogDirectoryPath
    )

    # Create the log directory if it doesn't exist
    if (-not (Test-Path -Path $LogDirectoryPath -PathType Container)) {
        New-Item -ItemType Directory -Path $LogDirectoryPath
        Write-Host "Folder '$LogDirectoryPath' created successfully."
    } else {
        Write-Host "Folder '$LogDirectoryPath' already exists."
    }

    # Get the current ACL of the log directory
    $acl = Get-Acl -Path $LogDirectoryPath

    # Define the identity (local Users group) and the access rights
    $identity = "BUILTIN\Users"
    $fileSystemRights = `
      [System.Security.AccessControl.FileSystemRights]::Write, `
      [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles

    # Create a new FileSystemAccessRule
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $identity,
        $fileSystemRights,
        [System.Security.AccessControl.AccessControlType]::Allow
    )

    # Add the new access rule to the ACL
    $acl.AddAccessRule($accessRule)

    # Apply the modified ACL to the folder
    Set-Acl -Path $LogDirectoryPath -AclObject $acl
}


# Get the full path of the current script
$scriptPath = $MyInvocation.MyCommand.Path

# Get the directory of the current script
$scriptDirectory = Split-Path -Parent $scriptPath

# Define the script directory in ProgramData
$ScriptFolder = "$env:ProgramData\Scripts\TotalMixMultiUser"

# Ensure the %ProgramData%\Scripts\TotalMixMultiUser directory exists
if (-not (Test-Path $ScriptFolder)) {
  New-Item `
    -Force `
    -ItemType Directory `
    -Path $ScriptFolder
}

# Copy all items in the script directory, excluding this script
Get-ChildItem -Path $scriptDirectory | `
  Where-Object { $_.FullName -ne $scriptPath } | `
  Copy-Item -Destination $ScriptFolder -Force

# Initialize the log directory and its ACLs
InitializeTotalMixLogDirectory -LogDirectoryPath "$ScriptFolder\Logs"

# Register TotalMixFX MultiUser Start Task
Register-TotalMixTask `
  -TaskName "TotalMixFX MultiUser Start" `
  -Description "Starts TotalMixFX for current User on logon." `
  -ScriptName "StartTotalMixFX.ps1" `
  -GroupId "S-1-5-32-545" `
  -RunLevel "LeastPrivilege" `
  -SessionStates @("Unlock", "ConsoleConnect") `
  -LogonDelaySeconds 5

# Register TotalMixFX MultiUser Terminate Task
Register-TotalMixTask `
  -TaskName "TotalMixFX MultiUser Terminate" `
  -Description "Terminates all TotalMixFX Instances on Login." `
  -ScriptName "TerminateTotalMixFX.ps1" `
  -UserId "S-1-5-18" `
  -RunLevel "Highest" `
  -SessionStates @("RemoteConnect", "Unlock")

Write-Host "Scheduled tasks for multiuser support of TotalMix FX and ARC/USB have been created."
Write-Host "Installation complete. Please restart your computer to apply the changes."
