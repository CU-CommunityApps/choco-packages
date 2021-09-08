# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process "$INSTALL_DIR\install-revit-cornell.bat" -wait