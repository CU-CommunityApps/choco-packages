# Runs before the choco package is installed

# Install prereq's
Start-Process "$INSTALL_DIR\NDP481-x86-x64-AllOS-ENU.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait
