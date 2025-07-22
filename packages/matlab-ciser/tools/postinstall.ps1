# Runs after the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item "$INSTALL_DIR\network.lic" "c:\Program Files\MATLAB\R2025a\licenses\network.lic"
