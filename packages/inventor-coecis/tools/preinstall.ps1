# Runs before the choco package is installed

start-sleep -second 60
Start-Process "$INSTALL_DIR\install\Installinventor.lnk" -ArgumentList "/quiet /norestart" -wait
