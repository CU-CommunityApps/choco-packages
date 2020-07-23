  
# Runs before the choco package is installed

#Install .NET
Start-Process "$INSTALL_DIR\ndp48-x86-x64-allos-enu.exe" -ArgumentList "/quiet /norestart" -Wait

#Install other pre-reqs
Start-Process "$INSTALL_DIR\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait
