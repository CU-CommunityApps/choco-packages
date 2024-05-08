# Runs before the choco package is installed

#Chrome download

Start-BitsTransfer "https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" -Destination "%TOOLS_DIR%\GoogleChromeStandaloneEnterprise64.msi"

## 7 Zip latest download link

$7Zip = "https://www.7-zip.org/$((Invoke-WebRequest https://www.7-zip.org/download.html | Select-Object -ExpandProperty Links | Where-Object -Property href -like "*-x64.msi")[0].href)"

Start-BitsTransfer "$7Zip" -Destination "%TOOLS_DIR%\7zip.msi"

## Notepad ++ Download

$linkPath = ((Invoke-WebRequest -URI https://notepad-plus-plus.org -UseBasicParsing) | Select-Object -ExpandProperty links | Where-Object -Property href -like "/downloads/v*").href 
$downloadurl = "https://notepad-plus-plus.org$linkpath"
$NotePadPlusPlus = ((Invoke-WebRequest -URI $downloadurl -UseBasicParsing) | Select-Object -ExpandProperty links | Where-Object -Property href -like "*npp.*.installer.x64.exe").href | Select-Object -Index 0

Start-BitsTransfer "$NotePadPlusPlus" -Destination "%TOOLS_DIR%\NotePadPlusPlus.exe"

# Check OS Version
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Enable Windows Defender
If($OSVersion -notmatch "2012")
{
    # Enable WinDefend
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -force -ErrorAction SilentlyContinue
     
    # Start WindDefend
    Start-Service -Name WinDefend -ErrorAction SilentlyContinue
}
