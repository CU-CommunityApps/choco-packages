# Runs after the choco package is installed

#Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Fix Updated Browser Warnings
Start-Process -filepath $env:windir\regedit.exe -Argumentlist "/s $INSTALL_DIR\adobe.reg"

# Remove Adobe Updater Scheduled Task
SCHTASKS /DELETE /TN "AdobeCCAppRegistration-AdobeNotificationClient_2.0.1.8_x86_enpm4xejd91yc" /F

# Stop and disable updater services
Stop-Service AdobeUpdateService -Force
Set-Service AdobeUpdateService -StartupType Disabled
