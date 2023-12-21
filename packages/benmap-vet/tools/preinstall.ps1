# Runs before the choco package is installed

# Install prereq's
Start-Process "$INSTALL_DIR\NDP481-x86-x64-AllOS-ENU.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redistx64.exe" -ArgumentList "/quiet /norestart" -Wait

#Install Databases
Expand-Archive -Path $INSTALL_DIR\BENMAP50.zip -DestinationPath "$env:SYSTEMDRIVE\Users\Default\AppData\Local\BenMAP-CE\Database"
Expand-Archive -Path $INSTALL_DIR\BENMAP50_GBD.zip -DestinationPath "$env:SYSTEMDRIVE\Users\Default\AppData\Local\BenMAP-CE\Database"
Expand-Archive -Path $INSTALL_DIR\POPSIMDB.zip -DestinationPath "$env:SYSTEMDRIVE\Users\Default\AppData\Local\BenMAP-CE\Database"
