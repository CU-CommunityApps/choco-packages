# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

gci -Path $INSTALL_DIR\Microsoft* -Filter *.exe -Recurse | % {Start-Process $_.FullName -ArgumentList "/q /norestart" -wait -Verbose}
