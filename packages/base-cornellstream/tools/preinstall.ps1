# Runs before the choco package is installed

# Enable Windows Defender
If($OSVersion -notmatch "2012")
{
    # Enable WinDefend
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -force -ErrorAction SilentlyContinue

    # Start WindDefend
    Start-Service -Name WinDefend
    
}
