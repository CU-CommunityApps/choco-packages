# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

Start-Process "msiexec.exe" -Wait -ArgumentList "/i $INSTALL_DIR\SSCERuntime_x86-ENU.msi /qb /norestart"
Start-Process "msiexec.exe" -Wait -ArgumentList "/i $INSTALL_DIR\SSCERuntime_x64-ENU.msi /qb /norestart"
Start-Process "$INSTALL_DIR\vcredist.x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\vcredist_x64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\haspdinst.exe" -ArgumentList "-install -nomsg"
