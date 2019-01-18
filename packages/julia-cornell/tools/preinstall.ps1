# Runs before the choco package is installed
Start-Process "$env:ALLUSERSPROFILE\chocolatey\choco.exe" -ArgumentList "install julia --confirm --install-arguments=/D=C:\ProgramData\Julia"
