# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Install prereq's
Start-Process "$INSTALL_DIR\PreReqs\dotNetFx\ndp48-x86-x64-allos-enu.exe" -ArgumentList "/quiet /norestart" -Wait

Copy-Item -Path "$INSTALL_DIR\startbaja.cmd" -Destination "C:\"
Copy-Item -Path "$INSTALL_DIR\Baja_Vault" -Destination "C:\"

gci -Path $INSTALL_DIR\Microsoft* -Filter *.exe -Recurse | % {Start-Process $_.FullName -ArgumentList "/q /norestart" -wait -Verbose}
