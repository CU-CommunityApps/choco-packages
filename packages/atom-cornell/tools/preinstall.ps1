# Runs before the choco package is installed
# Install Julia.exe in specified location
Start-Process "$env:ALLUSERSPROFILE\chocolatey\choco.exe" -ArgumentList "install atom --confirm --install-arguments=/D=C:\ProgramData\atom" -Wait -NoNewWindow
