# Runs before the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

#Install other pre-reqs
Start-Process "$INSTALL_DIR\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\windowsdesktop-runtime-8.0.8-win-x64.exe" -ArgumentList "/quiet /norestart" -Wait
Start-Process "$INSTALL_DIR\MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -ArgumentList "/silent /install" -Wait
