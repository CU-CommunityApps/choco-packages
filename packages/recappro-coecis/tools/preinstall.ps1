# Runs before the choco package is installed 

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process "$INSTALL_DIR\install-recappro-coecis.bat" -wait