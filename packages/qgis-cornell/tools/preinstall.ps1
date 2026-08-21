# Runs before the choco package is installed

#Download latest version of QGIS
#$data = Invoke-WebRequest -Uri "https://www.qgis.org/download/" -UseBasicParsing
 
#$filteredData = $data.Links | Where-Object -Property outerHTML -like "*Latest Version for Windows*"

#if ($filteredData.count -gt 1) {
#     $link = $filteredData[0].href }
#else {
#     $link = $filteredData.href
#}
 
#$downloadLink = "https://www.qgis.org" + $link
 
$downloadLink = "https://download.qgis.org/downloads/QGIS-OSGeo4W-3.44.13-1.msi"
Start-BitsTransfer -Source $downloadLink -Destination "$PSScriptRoot\qgis.msi"
