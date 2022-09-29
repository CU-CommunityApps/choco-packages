# Runs after the choco package is installed

#Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Fix Updated Browser Warnings
Start-Process -filepath $env:windir\regedit.exe -Argumentlist "/s $INSTALL_DIR\adobe.reg"

# Stop and disable updater services
Stop-Service AdobeUpdateService -Force
Set-Service AdobeUpdateService -StartupType Disabled

#Remove Adobe Notifications
Get-AppxPackage -AllUsers *AdobeNotificationClient* | Remove-AppxPackage -AllUsers

# Copy missing Photoshop 2022 settings and libraries
$path = "$env:SYSTEMDRIVE\Users\Default\AppData\Roaming\Adobe\Adobe Photoshop 2022\"
cp "$TOOLS_DIR\Adobe Photoshop 2022 Settings" $path -Recurse
