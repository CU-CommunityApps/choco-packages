# Enable WinDefend
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -force
    
# Start WindDefend
Start-Service -Name WinDefend
    
# Apply custom policies
## https://docs.microsoft.com/en-us/powershell/module/defender/Set-MpPreference?view=win10-ps ##
Set-MpPreference -UILockdown:$False -ExclusionPath "$env:USERPROFILE\My Files" -SignatureFallbackOrder {MMPC | MicrosoftUpdateServer} -SignatureUpdateInterval 1 -SignatureFirstAuGracePeriod 5 -SignatureAuGracePeriod 5 -SubmitSamplesConsent Never -CheckForSignaturesBeforeRunningScan $True -DisableRealTimeMonitoring $False -ExclusionProcess "StorageConnector.exe", "dcvserver.exe", "dcvagent.exe", "PhotonAgentWebServer.exe", "PhotonAgent.exe", "PhotonWindowsAppSwitcher.exe", "PhotonWindowsCustomerShell*.exe", "amazon-cloudwatch-agent.exe", "*amazon*.*", "*Photon*.*" -DisableRestorePoint $True -DisableScanningMappedNetworkDrivesForFullScan $True -DisableScanningNetworkFiles $True  -ThrottleLimit 10 -DisableBehaviorMonitoring $True -DisableCatchupFullScan $True -MAPSReporting Disabled -RealtimeScanDirection Incoming -RemediationScheduleDay Never -ScanAvgCPULoadFactor 10 -ScanOnlyIfIdleEnabled $True -ScanParameters QuickScan -ScanScheduleQuickScanTime 960 -SevereThreatDefaultAction Remove 

Start-Sleep -Seconds 10

# Update Defender
Update-MpSignature -Verbose
