# Runs before the choco package is installed 
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Install prereq's - for some reason was failing - maybe a zip file issue?
#Start-Process "$INSTALL_DIR\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait
#Start-Process "$INSTALL_DIR\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait
#Start-Process "$INSTALL_DIR\msmpisetup.exe" -ArgumentList "-unattend -minimal" -Wait
