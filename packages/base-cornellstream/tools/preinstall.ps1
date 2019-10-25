# Runs before the choco package is installed

# Check OS Version
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Reinstall Windows Defender on Server 2016
If($OSVersion -match "2016"){Install-WindowsFeature -Name Windows-Defender}

# Enable Windows Defender
If($OSVersion -match "2019")
{
    # Enable WinDefend
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -force -ErrorAction SilentlyContinue

    # Start WindDefend
    Start-Service -Name WinDefend
}
