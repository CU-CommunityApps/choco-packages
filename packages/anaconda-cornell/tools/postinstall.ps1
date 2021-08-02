# Runs after the choco package is installed

start-sleep -second 60
Start-Process "$INSTALL_DIR\CornellExtensionsInstall\install.lnk" -ArgumentList "/quiet /norestart" -force
