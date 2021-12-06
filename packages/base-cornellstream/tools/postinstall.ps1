# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F
Stop-Service gupdate
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem
Set-Service gupdatem -StartupType Disabled

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

# Setup Windows Defender Preferences for Server 2016 or 2019 (not 2012)
If($OSVersion -notmatch "2012")
{
    # Apply custom policies
    ## https://docs.microsoft.com/en-us/powershell/module/defender/Set-MpPreference?view=win10-ps ##
    Set-MpPreference -UILockdown:$False -ExclusionPath "$env:SYSTEMDRIVE\Users\*\My Files, $env:ALLUSERSPROFILE\UserDataFolders" -SignatureFallbackOrder {MicrosoftUpdateServer | MMPC} -SignatureUpdateInterval 1 -SignatureFirstAuGracePeriod 5 -SignatureAuGracePeriod 5 -SubmitSamplesConsent Never -CheckForSignaturesBeforeRunningScan $True -DisableRealTimeMonitoring $False -ExclusionProcess "StorageConnector.exe", "dcvserver.exe", "dcvagent.exe", "PhotonAgentWebServer.exe", "PhotonAgent.exe", "PhotonWindowsAppSwitcher.exe", "PhotonWindowsCustomerShell*.exe", "amazon-cloudwatch-agent.exe", "*amazon*.*", "*Photon*.*" -DisableRestorePoint $True -DisableScanningMappedNetworkDrivesForFullScan $True -DisableScanningNetworkFiles $True  -ThrottleLimit 10 -DisableBehaviorMonitoring $True -DisableCatchupFullScan $True -MAPSReporting Disabled -RealtimeScanDirection Incoming -RemediationScheduleDay Never -ScanAvgCPULoadFactor 10 -ScanOnlyIfIdleEnabled $True -ScanParameters QuickScan -ScanScheduleQuickScanTime 960 -SevereThreatDefaultAction Remove 

    Start-Sleep -s 10
    
    # Update Defender
    Update-MpSignature -verbose
}

#################################
# Set Application Calalog order #
#################################

# Commented out potentially temporarily for testing

# # Image Assistant DB
# $APP_CATALOG = [io.path]::combine($Env:ALLUSERSPROFILE, 'Amazon', 'Photon', 'PhotonAppCatalog.sqlite')

# # SQL Query to Update Table
# $query = "CREATE TABLE New AS SELECT * FROM Applications ORDER BY DisplayName COLLATE NOCASE DESC;
# DROP TABLE Applications;
# CREATE TABLE Applications AS SELECT * FROM New ORDER BY DisplayName COLLATE NOCASE DESC;
# DROP TABLE New;"

# # Update Table
# Invoke-SqliteQuery -DataSource $APP_CATALOG -Query $query
