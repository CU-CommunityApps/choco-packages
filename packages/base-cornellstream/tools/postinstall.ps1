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

#Setup Windows Defender Preferences for Server 2016 or 2019 (not 2012)
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

If($OSVersion -notmatch "2012")
{
Set-MpPreference -UILockdown:$False -ExclusionPath "%USERPROFILE%\My Files" -SignatureFallbackOrder {MMPC | MicrosoftUpdateServer} -SignatureScheduleDay Everyday -SignatureScheduletime 480 -SignatureFirstAuGracePeriod 15 -SignatureAuGracePeriod 20 -SubmitSamplesConsent Never -CheckForSignaturesBeforeRunningScan $True -DisableRealTimeMonitoring $False -ExclusionProcess "StorageConnector.exe", "dcvserver.exe", "dcvagent.exe", "PhotonAgentWebServer.exe", "PhotonAgent.exe", "PhotonWindowsAppSwitcher.exe", "PhotonWindowsCustomerShell*.exe", "amazon-cloudwatch-agent.exe", "*amazon*.*", "*Photon*.*" -DisableRestorePoint $True -DisableScanningMappedNetworkDrivesForFullScan $True -DisableScanningNetworkFiles $True  -ThrottleLimit 10 -DisableBehaviorMonitoring $True -DisableCatchupFullScan $True -MAPSReporting Disabled -RealtimeScanDirection Incoming -RemediationScheduleDay Never -ScanAvgCPULoadFactor 10 -ScanOnlyIfIdleEnabled $True -ScanParameters QuickScan -ScanScheduleQuickScanTime 960 -SevereThreatDefaultAction Remove 
}
