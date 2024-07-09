# Runs before the choco package is installed

#Download latest version of QGIS
$data = Invoke-WebRequest -Uri "https://www.qgis.org/en/site/forusers/download.html" -UseBasicParsing 

$filterdData = $data.Links | Where-Object -Property href -like "*.msi"

$downloadLink = $filterdData[0].href

Start-BitsTransfer -Source $downloadLink -Destination "C:\Users\lb30\Documents\GettingStarted\qgis.msi"
