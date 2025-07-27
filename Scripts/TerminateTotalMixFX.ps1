# TerminateTotalMixFX.ps1

# See https://mslinn.com/av_studio/320-totalmix-multi-user.html
# Thanks to maggie33 for the original version of this script
# (https://forum.rme-audio.de/viewtopic.php?pid=239871#p239871)

# Find the TotalMixFX executable, avoiding TotalMixFX Remote
$exePath = Get-ChildItem `
  -Exclude "*remote*" `
  -File `
  -Include "Totalmix*.exe" `
  -Path "$($env:ProgramFiles)\RME" `
  -Recurse

$processName = `
  [System.IO.Path]::GetFileNameWithoutExtension($exePath)

$logPath = "$($PSScriptRoot)\TerminateTotalMixFX.log"

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Add-Content `
  -Path $logPath `
  -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Kill Script started by $currentUser"

# Retrieve all running instances of the target process
$runningTotalmixProcesses = Get-Process `
  -Name $processName `
  -ErrorAction SilentlyContinue

foreach ($proc in $runningTotalmixProcesses) {
    try {
        # Use WMI to get the process owner
        $wmi = Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE ProcessId = $($proc.Id)"
        $ownerInfo = $wmi.GetOwner()

        if ($ownerInfo -and $ownerInfo.User) {
            $owner = "$($ownerInfo.Domain)\$($ownerInfo.User)"

            if ($owner -eq $currentUser) {
                # Found an instance owned by the current user
                Add-Content `
                  -Path $logPath `
                  -Value ">> Preserved TotalMix process for current user ($owner) with PID $($proc.Id)"
            } else {
                # Kill instances not owned by the current user
                Stop-Process -Id $proc.Id -Force
                Add-Content `
                  -Path $logPath `
                  -Value ">> Terminated TotalMix instance for user $owner with PID $($proc.Id)"
            }
        } else {
            # Could not determine the process owner
            Add-Content `
              -Path $logPath `
              -Value ">> No owner found for TotalMix process with PID $($proc.Id)"
        }

    } catch {
        # Catch and log any errors during process handling
        Add-Content `
          -Path $logPath `
          -Value "!! Error processing PID $($proc.Id): $_"
    }
}
