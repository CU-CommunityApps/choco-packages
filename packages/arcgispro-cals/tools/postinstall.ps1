# Runs after the choco package is installed
Start-Process msiexec.exe -ArgumentList '/p %INSTALL_DIR%\ArcGISd1\ArcGIS_Pro_241_170796.msp /qn'
