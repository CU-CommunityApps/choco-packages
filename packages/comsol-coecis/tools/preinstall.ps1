# Runs before the choco package is installed

# Microsoft.NET Framework 4.6 (REQUIRED)
Start-Process "$env:INSTALL_DIR\ndp48-x86-x64-allos-enu.exe" -ArgumentList "/q /lang:ENU /norestart" -Wait
