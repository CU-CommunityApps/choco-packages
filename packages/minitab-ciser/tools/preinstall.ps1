# Runs before the choco package is installed

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Copy-Item "$INSTALL_DIR\minitab.lic" "$env:ProgramFiles\Minitab\Minitab 19\minitab.lic"
