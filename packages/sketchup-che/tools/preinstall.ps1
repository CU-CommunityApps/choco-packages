# Runs before the choco package is installed

# Install prereq's
Start-Process "$INSTALL_DIR\VC_redistx64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redistx86.exe" -ArgumentList "/quiet /norestart" -Wait
