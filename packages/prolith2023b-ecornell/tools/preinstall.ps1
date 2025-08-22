# Runs before the choco package is installed
$destDir = Split-Path "$env:PROGRAMFILES\PROLITH_Toolkit\PROLITH 2023b\PROLITHDatabase.DB"  
if (!(Test-Path $destDir)) {  
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null  
}  
  
Copy-Item "$env:INSTALL_DIR\PROLITHDatabase.DB" "$env:PROGRAMFILES\PROLITH_Toolkit\PROLITH 2023b\PROLITHDatabase.DB" -Force
