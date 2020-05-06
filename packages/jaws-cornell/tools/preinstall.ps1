# Runs before the choco package is installed

# Install prereq's 2010
Start-Process "$INSTALL_DIR\2010vcredist_x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\2010vcredist_x64.exe" -ArgumentList "/quiet /norestart" -Wait

# Install prereq's 2010
Start-Process "$INSTALL_DIR\2013vcredist_x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\2013vcredist_x64.exe" -ArgumentList "/quiet /norestart" -Wait
