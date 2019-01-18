# Runs before the choco package is installed
Start-Process "$env:ALLUSERSPROFILE\chocolatey\choco.exe" -ArgumentList "install julia --install-arguments=/D=C:\ProgramData\Ju
lia"
