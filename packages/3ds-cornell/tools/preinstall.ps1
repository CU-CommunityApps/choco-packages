# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# File contains chars that chocolatey will not extract, copying manually before installation
Copy-Item -Path "$PSScriptRoot\ArchVisionC1Tina2.rpc" -Destination "$INSTALL_DIR\x64\RX\PF32\CF32\AS32\Materials\2022\assetlibrary_base.fbm\RPCs\ArchVision_C1_Tina[2].rpc" -Force