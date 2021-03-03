# Runs before the choco package is installed

Copy-Item -Path "$TOOLS_DIR\setup.iss" -Destination $env:SYSTEMDRIVE\windows\setup.iss
