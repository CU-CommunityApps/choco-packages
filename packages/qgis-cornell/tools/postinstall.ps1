# Runs after the choco package is installed
Invoke-WebRequest https://ubuntu.qgis.org/version.txt

Expand-Archive -LiteralPath "$TOOLS_DIR\QGIS3.zip" -DestinationPath '%SYSTEMDRIVE%\Users\Default\AppData\Roaming'
