# Runs before the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# https://forums.autodesk.com/t5/installation-licensing/installatoin-hangs-at-adsklicensing-installer-exe/m-p/8842099#M223832
Start-Process "AdskLicensing-installer.exe" -WorkingDirectory $INSTALL_DIR

Start-Sleep -s 120
