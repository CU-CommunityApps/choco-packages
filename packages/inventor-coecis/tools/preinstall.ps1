# Runs before the choco package is installed 

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Copy-Item -Path %INSTALL_DIR%\image -Destination $SYSTEMDRIVE%\ -PassThru

Start-Process "$INSTALL_DIR\install-inventor-coecis.bat" -wait
