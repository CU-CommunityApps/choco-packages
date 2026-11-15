# Runs before the choco package is installed

$RStudio = ((Invoke-WebRequest -Uri "https://docs.posit.co/ide/user/download.html" -UseBasicParsing).Links | Where-Object -Property "href" -like "*.zip" | where-object -Property "href" -NotMatch "pro").href

Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.zip"

Expand-Archive -Path "$PSScriptRoot\RStudio.zip" -DestinationPath "C:\Program Files\RStudio" -Force
