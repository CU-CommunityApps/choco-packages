# Runs before the choco package is installed

# Copy License File to ProgramData
Copy-Item "$INSTALL_DIR\network.lic" "C:\ProgramData\network.lic"

