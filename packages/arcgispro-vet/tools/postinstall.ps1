# Runs after the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process msiexec.exe -ArgumentList '/p $INSTALL_DIR\ArcGISd1\ArcGIS_Pro_281_177644.msp /qn /norestart'
