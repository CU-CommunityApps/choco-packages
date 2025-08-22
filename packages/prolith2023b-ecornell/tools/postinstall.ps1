# Runs after the choco package is installed
Copy-Item "$env:INSTALL_DIR\PROLITHDatabase.DB" "$env:PROGRAMFILES\PROLITH_Toolkit\PROLITH 2023b\PROLITHDatabase.DB" -Force
