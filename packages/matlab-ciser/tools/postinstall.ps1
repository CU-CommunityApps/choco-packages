# Runs after the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item "$env:INSTALL_DIR\network.lic" "c:\Program Files\MATLAB\R2024a\licenses\network.lic"
