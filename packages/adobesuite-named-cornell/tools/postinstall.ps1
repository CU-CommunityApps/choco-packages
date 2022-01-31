# Runs after the choco package is installed

#Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Fix Updated Browser Warnings
Start-Process -filepath $env:windir\regedit.exe -Argumentlist "/s $INSTALL_DIR\adobe.reg"

# Stop and disable updater services
Stop-Service AdobeUpdateService -Force
Set-Service AdobeUpdateService -StartupType Disabled

#Remove Adobe Notifications
Get-AppxPackage -Name AdobeNotificationClient | Remove-AppxPackage 
