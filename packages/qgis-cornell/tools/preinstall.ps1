# Runs before the choco package is installed

#Download latest version of QGIS
$data = Invoke-WebRequest -Uri "https://www.qgis.org/en/site/forusers/download.html" -UseBasicParsing
 
$filterdData = $data.Links | Where-Object -Property outerHTML -like "*Latest Version for Windows*"
 
$downloadLink = $filterdData.href
 
Start-BitsTransfer -Source $downloadLink -Destination "$PSScriptRoot\qgis.msi"
