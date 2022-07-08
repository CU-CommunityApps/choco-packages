# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process Powershell -ArgumentList "-File $INSTALL_DIR\Deploy-Autodesk_3ds_Max_2023.ps1"
