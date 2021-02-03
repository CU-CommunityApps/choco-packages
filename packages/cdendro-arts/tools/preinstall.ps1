# Runs before the choco package is installed
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All 

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'
Copy-Item -Path "$INSTALL_DIR\" -Destination "C:\Program Files (x86)\Cybis" -recurse
