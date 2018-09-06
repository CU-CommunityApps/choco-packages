# Runs before the choco package is installed
Copy-item "$env:INSTALL_DIR\scripts" -Destination "$env:ProgramFiles\Tableau\Tableau 2018.1\bin\scripts" -Recurse