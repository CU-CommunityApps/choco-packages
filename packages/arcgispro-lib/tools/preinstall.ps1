  
# Runs before the choco package is installed

# Install .Net
Start-Process "$INSTALL_DIR\ndp48-x86-x64-allos-enu.exe" -ArgumentList "/quiet /norestart" -Wait
# Install c++
Start-Process "$INSTALL_DIR\VC_redistx64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redistx86.exe" -ArgumentList "/quiet /norestart" -Wait
