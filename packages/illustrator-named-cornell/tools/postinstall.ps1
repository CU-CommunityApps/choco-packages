# Runs after the choco package is installed

#Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Fix Updated Browser Warnings
Start-Process -filepath $env:windir\regedit.exe -Argumentlist "/s $INSTALL_DIR\adobe.reg"
