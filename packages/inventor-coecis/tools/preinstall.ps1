# Runs before the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item -Path %INSTALL_DIR%\inventor -Destination c:\inventor -Recurse
