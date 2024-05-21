# Runs before the choco package is installed

$RStudio = ((Invoke-WebRequest -Uri "https://posit.co/download/rstudio-desktop/").Links | Where-Object -Property "href" -like "*.zip").href

Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.zip"

Invoke-Expression "7z x `"$PSScriptRoot\RStudio.zip`" -y -bd -o`"C:\Program Files\RStudio`""