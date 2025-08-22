# Runs before the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item "$env:INSTALL_DIR\startbaja.cmd" "%SYSTEMDRIVE%\"
Copy-Item "$env:INSTALL_DIR\Baja_Vault.cvs" "%SYSTEMDRIVE%\"

gci -Path $INSTALL_DIR\Microsoft* -Filter *.exe -Recurse | % {Start-Process $_.FullName -ArgumentList "/q /norestart" -wait -Verbose}
