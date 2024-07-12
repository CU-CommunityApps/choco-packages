# Runs before the choco package is installed

#Download latest version of QGIS
$data = Invoke-WebRequest -Uri "https://www.qgis.org/download/" -UseBasicParsing
 
$filterdData = $data.Links | Where-Object -Property outerHTML -like "*Latest Version for Windows*"
 
$downloadLink = "https://www.qgis.org" + $filterdData.href
 
Start-BitsTransfer -Source $downloadLink -Destination "$PSScriptRoot\qgis.msi"
