# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

Copy-Item -Path "$INSTALL_DIR\startbaja.cmd" -Destination "C:\"
Copy-Item -Path "$INSTALL_DIR\Baja_Vault" -Destination "C:\"

gci -Path $INSTALL_DIR\Microsoft* -Filter *.exe -Recurse | % {Start-Process $_.FullName -ArgumentList "/q /norestart" -wait -Verbose}
