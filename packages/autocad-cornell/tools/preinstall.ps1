# Runs before the choco package is installed
Write-Output $PSScriptRoot
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'
Write-Output $INSTALL_DIR

# https://forums.autodesk.com/t5/installation-licensing/installatoin-hangs-at-adsklicensing-installer-exe/m-p/8842099#M223832
Start-Process "AdskLicensing-installer.exe" -ArgumentList "--mode unattended --unattendedmodeui none" -WorkingDirectory $INSTALL_DIR
