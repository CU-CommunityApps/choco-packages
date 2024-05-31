# Runs before the choco package is installed

#Download latest version of R

$url = "https://cloud.r-project.org//bin/windows/base/$((Invoke-WebRequest -Uri "https://cloud.r-project.org/bin/windows/base/" -UseBasicParsing | Select-Object -ExpandProperty Links | Where-Object href -like "*win.exe")[0].href)" 

Start-BitsTransfer $url -Destination "$PSScriptRoot\RInstall.exe"