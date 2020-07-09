# Runs before the choco package is installed
If (!(Test-Path "$env:ALLUSERSPROFILE\Granta Design\CES EduPack 2020")){New-Item "$env:ALLUSERSPROFILE\Granta Design\CES EduPack 2020" -ItemType Directory -Force}
Copy-Item "$env:INSTALL_DIR\license.lic" -Destination "$env:ALLUSERSPROFILE\Granta Design\CES EduPack 2020"
