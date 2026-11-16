# Runs before the choco package is installed

##$RStudio = ((Invoke-WebRequest -Uri "https://docs.posit.co/ide/user/download.html" -UseBasicParsing).Links | Where-Object -Property "href" -like "*.zip" | where-object -Property "href" -NotMatch "pro").href

##this is supposed to be a permalink to an exe installer
#$Rstudio = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
#Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.exe"

#Expand-Archive -Path "$PSScriptRoot\RStudio.zip" -DestinationPath "C:\Program Files\RStudio" -Force


# Only downloads the installer; config.yml (Install:) runs it with silent switches.

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# choco can leave TEMP/TMP unset (same guard as the k2client fix); the installer needs them
if (-not $env:TEMP) { $env:TEMP = 'C:\Windows\Temp' }
if (-not $env:TMP)  { $env:TMP  = $env:TEMP }

# Permalink: 302 -> https://s3.amazonaws.com/rstudio-desktop/electron/windows/RStudio-<version>.exe
$url  = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
$dest = Join-Path $PSScriptRoot "RStudio-Setup.exe"

Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
