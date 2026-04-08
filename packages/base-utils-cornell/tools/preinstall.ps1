# Runs before the choco package is installed
$TOOLS_DIR = $PSScriptRoot

#Chrome download
Start-BitsTransfer "https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" -Destination "$TOOLS_DIR\GoogleChromeStandaloneEnterprise64.msi"

## 7 Zip latest download link
$7Zip = "https://www.7-zip.org/$((Invoke-WebRequest -Uri "https://www.7-zip.org/download.html" -UseBasicParsing | Select-Object -ExpandProperty Links | Where-Object -Property href -like "*-x64.msi")[0].href)"
Start-BitsTransfer "$7Zip" -Destination "$TOOLS_DIR\7zip.msi"

## Notepad ++ Download
##example after website changes April 2026
##https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.3/npp.8.9.3.Installer.x64.exe
#$linkPath = ((Invoke-WebRequest -URI https://notepad-plus-plus.org -UseBasicParsing) | Select-Object -ExpandProperty links | Where-Object -Property href -like "/downloads/v*").href 
#$downloadurl = "https://notepad-plus-plus.org$linkpath"


#$downloadurl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/"
#$NotePadPlusPlus = ((Invoke-WebRequest -URI $downloadurl -UseBasicParsing) | Select-Object -ExpandProperty links | Where-Object -Property href -like "*npp.*.installer.x64.exe").href | Select-Object -Index 0
#Start-BitsTransfer "$NotePadPlusPlus" -Destination "$TOOLS_DIR\NotePadPlusPlus.exe"