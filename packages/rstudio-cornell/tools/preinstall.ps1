# Runs before the choco package is installed

$RStudio = ((Invoke-WebRequest -Uri "https://posit.co/download/rstudio-desktop/").Links | Where-Object -Property "href" -like "*windows/RStudio*").href[0]

Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.exe"