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
      [ValidateSet("Limited", "Highest")]
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
      # See https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasktrigger
      if ($state -eq "Unlock") {
        # Create an event trigger for workstation unlock (Event ID 4801)
        $triggers += New-ScheduledTaskTrigger -AtEvent -Source 'Microsoft-Windows-Security-Auditing' -Id 4801
      } elseif ($state -eq "AtLogon") {
        $triggers += New-ScheduledTaskTrigger -AtLogon
      } else {
        $triggers += New-ScheduledTaskTrigger -At $state
      }
    }

    # Define principal
    if ($UserId) {
      $principal = New-ScheduledTaskPrincipal -UserId $UserId -RunLevel $RunLevel
    } elseif ($GroupId) {
      $principal = New-ScheduledTaskPrincipal -GroupId $GroupId -RunLevel $RunLevel
    }

    # Settings
    $idle = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd:$false -RestartOnIdle:$false

    $settings = New-ScheduledTaskSettingsSet `
      -AllowHardTerminate:$false `
      -AllowStartIfOnBatteries `
      -AllowStartOnDemand `
      -DisallowStartOnRemoteAppSession:$false `
      -Enabled `
      -ExecutionTimeLimit (New-TimeSpan -Seconds 0) `
      -Hidden:$false `
      -MultipleInstances IgnoreNew `
      -Priority 7 `
      -RunOnlyIfIdle:$false `
      -RunOnlyIfNetworkAvailable:$false `
      -StartWhenAvailable `
      -StopIfGoingOnBatteries `
      -UseUnifiedSchedulingEngine

    $settings.IdleSettings = $idle

    Register-ScheduledTask `
      -Action $Action `
      -Description $Description `
      -Principal $principal `
      -Settings $settings `
      -TaskName $TaskName `
      -TaskPath "\$scriptDirectory\" `
      -Trigger $triggers
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
      [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles, `
      [System.Security.AccessControl.FileSystemRights]::Write

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
  -Description "Starts TotalMixFX for current User on logon." `
  -GroupId "S-1-5-32-545" `
  -LogonDelaySeconds 5 `
  -RunLevel "Limited" `
  -ScriptName "StartTotalMixFX.ps1" `
  -SessionStates @("AtLogon") `
  -TaskName "TotalMixFX MultiUser Start"
# -SessionStates @("AtLogon", "ConsoleConnect", "Unlock") `


# Register TotalMixFX MultiUser Terminate Task
Register-TotalMixTask `
  -Description "Terminates all TotalMixFX Instances on Login." `
  -RunLevel "Highest" `
  -ScriptName "TerminateTotalMixFX.ps1" `
  -SessionStates @("AtLogon") `
  -TaskName "TotalMixFX MultiUser Terminate" `
  -UserId "S-1-5-18"
  # -SessionStates @("RemoteConnect", "Unlock")

Write-Host "Scheduled tasks for multiuser support of TotalMix FX and ARC/USB have been created."
Write-Host "Installation complete. Please restart your computer to apply the changes."
