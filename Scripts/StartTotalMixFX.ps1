# StartTotalMixFX.ps1

# See https://mslinn.com/av_studio/320-totalmix-multi-user.html
# Thanks to maggie33 for the original version of this script
# (https://forum.rme-audio.de/viewtopic.php?pid=239871#p239871)

# Fails if TotalMix is not running
$exePath = Get-Process | `
  Where {$_.ProcessName -Like "total*"} | `
  Select-Object Path
[System.IO.Path]::GetFileNameWithoutExtension($exePath)

$exePath = Get-ChildItem `
  -File `
  -Include "Totalmix*.exe" `
  -Path "$($env:ProgramFiles)\RME" `
  -Recurse

if (-not $exePath) {
  Write-Error "Error: TotalMix is not installed."
  exit
}

$processName = "TotalMixFX_arm64" # <-- Adjust if necessary (process as it appears in TaskManager without the .exe)
$exePath = "C:\Program Files\RME\Fireface\TotalMixFX_arm64.exe"  # <-- Adjust if necessary (path to the exe)
$logPath = "C:\ProgramData\Scripts\KillTotalMixFX.log"
# No further adjustments needed below here...

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Add-Content -Path $logPath -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Start Script started by $currentUser"


$hasOwnInstance = $false
Get-Process -Name $processName -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        # Use WMI to get the process owner
        $wmi       = Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE ProcessId = $($_.Id)"
        $ownerInfo = $wmi.GetOwner()

        if ($ownerInfo -and $ownerInfo.User) {
            $owner = "$($ownerInfo.Domain)\$($ownerInfo.User)"

            if ($owner -eq $currentUser) {
                $hasOwnInstance = $true
                Add-Content -Path $logPath -Value ">> Own instance already running (PID $($_.Id))"
            }
        }
    } catch {
        Add-Content -Path $logPath -Value "!! Error querying PID $($_.Id): $_"
    }
}

if (-not $hasOwnInstance) {
    try {
        Start-Process -FilePath $exePath
        Add-Content -Path $logPath -Value '>> TotalMixFX started'
    } catch {
        Add-Content -Path $logPath -Value "!! Error starting TotalMixFX: $_"
    }
}
