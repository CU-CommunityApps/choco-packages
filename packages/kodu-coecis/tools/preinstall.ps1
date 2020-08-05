# Runs before the choco package is installed

#Install .NET
Start-Process "$INSTALL_DIR\ndp48-x86-x64-allos-enu.exe" -ArgumentList "/quiet /norestart" -Wait

#Install xna
Start-Process "$INSTALL_DIR\xnafx40_redist.msi" -ArgumentList "/quiet /norestart" -Wait

