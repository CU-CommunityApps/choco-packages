$TOOLS_DIR = $PSScriptRoot

Start-BitsTransfer "https://emsfs.autodesk.com/utility/odis/1/installer/latest/AdODIS-installer.exe" -Destination "$TOOLS_DIR\AdODIS-installer.exe"
# Runs before the choco package is installed

Start-Process -FilePath "$TOOLS_DIR\AdODIS-installer.exe" -ArgumentList "--mode unattended --unattendedmodeui none" -Wait
