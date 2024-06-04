# Runs before the choco package is installed

$RStudio = ((Invoke-WebRequest -Uri "https://posit.co/download/rstudio-desktop/" -UseBasicParsing).Links | Where-Object -Property "href" -like "*.zip").href 

Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.zip"

Expand-Archive -Path "$PSScriptRoot\RStudio.zip" -DestinationPath "C:\Program Files\RStudio" -Force