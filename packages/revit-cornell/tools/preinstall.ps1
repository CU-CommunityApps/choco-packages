# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Tools dir location
$TOOLS_DIR = Join-Path $PSScriptRoot

# File contains chars that chocolatey will not extract, copying manually before installation
Copy-Item -Path "$TOOLS_DIR\ArchVision_C1_Tina[2].rpc" -Destination "$INSTALL_DIR\Img\x64\RVT\PF32\CF32\AS32\Materials\2021\assetlibrary_base.fbm\RPCs\ArchVision_C1_Tina[2].rpc" -Force
