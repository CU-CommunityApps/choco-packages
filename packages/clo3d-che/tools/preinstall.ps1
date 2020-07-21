# Runs before the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Install prereq's
Start-Process "$INSTALL_DIR\VC_redist_x64.exe" -ArgumentList "/quiet /norestart" -Wait