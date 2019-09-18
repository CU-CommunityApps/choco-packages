# Runs after the choco package is installed
# List of applications to remove
$app = "Firefox"

# Get uninstall info for each possible application
If (gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
gp | where {$_.DisplayName -match $app}){

    $install = gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
    gp | where {$_.DisplayName -match $app} | select DisplayName, InstallLocation, UninstallString
    
    Start-Process $install.UninstallString -ArgumentList "/S" -WorkingDirectory $install.InstallLocation -WindowStyle Hidden

}

#Setup Windows Defender Preferences
Set-MpPreference -UILockdown:$True -ExclusionProcess test ‑ScanAvgCPULoadFactor 20 ‑RemediationScheduleDay Sunday ‑RemediationScheduleTime 120
