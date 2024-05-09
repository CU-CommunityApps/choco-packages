# Runs before the choco package is installed

#Download latest version of R

$url = "https://cloud.r-project.org//bin/windows/base/$((Invoke-WebRequest https://cloud.r-project.org/bin/windows/base/ | Select -ExpandProperty Links | Where innerText -like "Download R*for Windows")[0].href)"

Start-BitsTransfer $url -Destination "$PSScriptRoot\RInstall.exe"