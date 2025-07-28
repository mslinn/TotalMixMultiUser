# Uninstallation script that removes both of the Scheduled Tasks created by the
# installation script (TotalMixFX Start and TotalMixFX Terminate) and optionally
# deletes the associated script directory.
#
# Run this script as administrator

# Uninstall.ps1

$TaskFolder = "TotalMix"
$TaskNames = @("TotalMixFX Start", "TotalMixFX Terminate")
$ScriptFolder = "$env:ProgramData\Scripts\TotalMix"

foreach ($task in $TaskNames) {
  $fullPath = "\$TaskFolder\$task"
  try {
    if (Get-ScheduledTask -TaskPath "\$TaskFolder\" -TaskName $task -ErrorAction Stop) {
      Unregister-ScheduledTask -TaskPath "\$TaskFolder\" -TaskName $task -Confirm:$false
      Write-Output "Removed scheduled task: $fullPath"
    }
  } catch {
    Write-Warning "Task '$fullPath' not found or could not be removed: $_"
  }
}

# Optionally delete the associated script folder
if (Test-Path $ScriptFolder) {
  try {
      Remove-Item -Path $ScriptFolder -Recurse -Force
      Write-Output "Deleted script folder: $ScriptFolder"
  } catch {
      Write-Warning "Could not delete script folder '$ScriptFolder': $_"
  }
} else {
  Write-Output "Script folder does not exist: $ScriptFolder"
}
