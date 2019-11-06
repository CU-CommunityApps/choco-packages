# Runs before the choco package is installed

# Check OS Version
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Enable Windows Defender
If($OSVersion -notmatch "2012")
{
    # Start WindDefend
    Start-Service -Name WinDefend -ErrorAction SilentlyContinue
}
