# Runs after the choco package is installed

Start-Process -FilePath "$env:PROGRAMFILES\SOLIDWORKS PDM\ViewSetup.exe" -ArgumentList "$env:SYSTEMDRIVE\Baja_Vault.cvs" -Wait