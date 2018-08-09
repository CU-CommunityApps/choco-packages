# Runs before the choco package is installed
Copy-item "$env:INSTALL_DIR\scripts" -Destination "$env:SYSTEMDRIVE\scripts" -Recurse
