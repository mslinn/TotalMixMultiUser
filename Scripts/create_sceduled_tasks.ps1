# Here is a PowerShell script that programmatically creates the two Scheduled Tasks (TotalMixFX Start and TotalMixFX Terminate) defined in your XML files, using the Register-ScheduledTask cmdlet.
#
# Assumptions:
# - The script is run with administrative privileges.
# - The paths and PowerShell scripts (StartTotalMixFX.ps1 and TerminateTotalMixFX.ps1) exist at %ProgramData%\Scripts\TotalMix.
# - The XML files for the Scheduled Tasks are located in the same directory as this script.

# TotalMixTaskSetup.ps1

$ScriptFolder = "$env:ProgramData\Scripts\TotalMix"
$TaskFolder = "TotalMix"

# Ensure script folder exists
if (-not (Test-Path $ScriptFolder)) {
  New-Item -ItemType Directory -Path $ScriptFolder -Force
}

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
      -TaskPath "\$TaskFolder\" `
      -Action $Action `
      -Trigger $triggers `
      -Principal $principal `
      -Settings $settings `
      -Description $Description
}

# Register Start Task
Register-TotalMixTask `
  -TaskName "TotalMixFX Start" `
  -Description "Starts TotalMixFX for current User on logon." `
  -ScriptName "StartTotalMixFX.ps1" `
  -GroupId "S-1-5-32-545" `
  -RunLevel "LeastPrivilege" `
  -SessionStates @("Unlock", "ConsoleConnect") `
  -LogonDelaySeconds 5

# Register Terminate Task
Register-TotalMixTask `
  -TaskName "TotalMixFX Terminate" `
  -Description "Terminates all TotalMixFX Instances on Login." `
  -ScriptName "TerminateTotalMixFX.ps1" `
  -UserId "S-1-5-18" `
  -RunLevel "Highest" `
  -SessionStates @("RemoteConnect", "Unlock")

# Output completion message
Write-Host "Scheduled tasks for multiuser support of TotalMix FX and ARC/USB have been created."
