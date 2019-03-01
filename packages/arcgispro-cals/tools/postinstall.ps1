# Runs after the choco package is installed
Start-Process msiexec.exe -ArgumentList "/p $env:INSTALL_DIR\ArcGISd5\ArcGIS_Pro_231_167399.msp /q"
