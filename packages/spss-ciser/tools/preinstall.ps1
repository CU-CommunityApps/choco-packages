# Runs before the choco package is installed
Start-Process "$env:INSTALL_DIR\vcredist_x64.exe" -ArgumentList "/q /norestart" -Wait
