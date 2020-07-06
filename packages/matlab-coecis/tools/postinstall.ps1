# Runs after the choco package is installed
Copy-Item "$env:INSTALL_DIR\network.lic" "c:\Program Files\MATLAB\R2020a\licenses\network.lic"
