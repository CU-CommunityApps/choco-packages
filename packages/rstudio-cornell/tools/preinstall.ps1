# Runs before the choco package is installed

##$RStudio = ((Invoke-WebRequest -Uri "https://docs.posit.co/ide/user/download.html" -UseBasicParsing).Links | Where-Object -Property "href" -like "*.zip" | where-object -Property "href" -NotMatch "pro").href

##this is supposed to be a permalink to an exe installer
#$Rstudio = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
#Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.exe"

#Expand-Archive -Path "$PSScriptRoot\RStudio.zip" -DestinationPath "C:\Program Files\RStudio" -Force

# Permalink: 302 -> https://s3.amazonaws.com/rstudio-desktop/electron/windows/RStudio-<version>.exe
$url  = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
$dest = Join-Path $PSScriptRoot "RStudio-latest.exe"

Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
