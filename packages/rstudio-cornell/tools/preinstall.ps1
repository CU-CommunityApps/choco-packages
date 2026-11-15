# Runs before the choco package is installed

##$RStudio = ((Invoke-WebRequest -Uri "https://docs.posit.co/ide/user/download.html" -UseBasicParsing).Links | Where-Object -Property "href" -like "*.zip" | where-object -Property "href" -NotMatch "pro").href

##this is supposed to be a permalink to an exe installer
#$Rstudio = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
#Start-BitsTransfer "$RStudio" -Destination "$PSScriptRoot\RStudio.exe"

#Expand-Archive -Path "$PSScriptRoot\RStudio.zip" -DestinationPath "C:\Program Files\RStudio" -Force


$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# choco can leave TEMP/TMP unset (same guard as the k2client fix)
if (-not $env:TEMP) { $env:TEMP = 'C:\Windows\Temp' }
if (-not $env:TMP)  { $env:TMP  = $env:TEMP }

$url       = "https://rstudio.org/download/latest/stable/desktop/windows/RStudio-latest.exe"
$installer = Join-Path $env:TEMP "RStudio-latest.exe"

Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing   # follows the 302 to S3

$p = Start-Process -FilePath $installer -ArgumentList "/S" -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "RStudio installer exited with code $($p.ExitCode)" }

Remove-Item $installer -Force -ErrorAction SilentlyContinue