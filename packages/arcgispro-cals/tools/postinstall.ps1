# Runs after the choco package is installed
Start-Process msiexec.exe -ArgumentList "/p $env:INSTALL_DIR\ArcGISd5\ArcGIS_Pro_221_164752d5.msp /q"
