# Runs after the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item "$INSTALL_DIR\network.lic" "c:\Program Files\MATLAB\R2024a\licenses\network.lic"

#Remove Matlab Shortcut
Remove-Item "c:\users\public\desktop\MATLAB R2024a.lnk"
