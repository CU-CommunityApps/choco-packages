# Runs after the choco package is installed
Start-Process msiexec.exe -ArgumentList '/p INSTALL_DIR\ArcGISd1\ArcGIS_Pro_251_173949.msp /qn'
Start-Process msiexec.exe -ArgumentList '/p INSTALL_DIR\ArcGISd1\ArcGIS_Pro_251_173950.msp /qn'
