# Runs before the choco package is installed

# Install prereq's 2010
Start-Process "$INSTALL_DIR\vcredist2010_x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\vcredist2010_x64.exe" -ArgumentList "/quiet /norestart" -Wait

# Install prereq's 2010
Start-Process "$INSTALL_DIR\vcredist2013_x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\vcredist2013_x64.exe" -ArgumentList "/quiet /norestart" -Wait
