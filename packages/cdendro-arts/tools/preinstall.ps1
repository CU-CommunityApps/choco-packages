# Runs before the choco package is installed
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All 

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'
Copy-Item -Path "$INSTALL_DIR\" -Destination "C:\PROGRAMFILES(x86)\Cybis" -recurse
