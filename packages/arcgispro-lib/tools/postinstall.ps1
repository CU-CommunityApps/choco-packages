# Runs after the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process msiexec.exe -ArgumentList '/p $INSTALL_DIR\ArcGISd1\ArcGIS_Pro_251_173949.msp /qn'
Start-Process msiexec.exe -ArgumentList '/p $INSTALL_DIR\ArcGISd1\ArcGIS_Pro_251_173950.msp /qn'
