# Runs after the choco package is installed

Start-Process -FilePath "$env:PROGRAMFILES\SOLIDWORKS PDM\ViewSetup.exe" -ArgumentList "$env:SYSTEMDRIVE\PDM\Baja_Vault.cvs /q" -Wait
