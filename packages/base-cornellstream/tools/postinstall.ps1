# Runs after the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# List of applications to remove
$app = "Firefox"

# Get uninstall info for each possible application
If (gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
gp | where {$_.DisplayName -match $app}){

    $install = gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
    gp | where {$_.DisplayName -match $app} | select DisplayName, InstallLocation, UninstallString
    
    Start-Process $install.UninstallString -ArgumentList "/S" -WorkingDirectory $install.InstallLocation -WindowStyle Hidden

}

$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Install and configure SCEP on Server 2012
If($OSVersion -match "2012")
{
    Start-Process "$INSTALL_DIR\SCEPInstall.exe" -ArgumentList "/s /q /policy $INSTALL_DIR\SCEPpolicy.xml" -Wait
    Register-ScheduledTask -TaskName "Update_SCEP" -Xml (Get-Content "$PSScriptRoot\Update_SCEP.xml" | Out-String)
}

#Setup Windows Defender Preferences for Server 2016 or 2019 (not 2012)
If($OSVersion -notmatch "2012")
{
    Register-ScheduledTask -TaskName "Update_WinDefend" -Xml (Get-Content "$PSScriptRoot\Update_WinDefend.xml" | Out-String)
}
