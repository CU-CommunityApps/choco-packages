# Runs before the choco package is installed


$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Install prereq's
Start-Process "$INSTALL_DIR\inventor\Install inventor.bat" -ArgumentList "/quiet /norestart" -Wait
