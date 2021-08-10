# Runs before the choco package is installed

Copy-Item -Path "%INSTALL_DIR%\inventor" -Destination "%SYSTEMDRIVE%\inventor" -Recurse
