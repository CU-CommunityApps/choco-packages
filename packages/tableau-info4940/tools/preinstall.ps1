# Runs before the choco package is installed
Copy-item '$(INSTALL_DIR)\scripts': '$env:SYSTEMDRIVE\scripts'
