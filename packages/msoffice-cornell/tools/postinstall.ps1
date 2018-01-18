# Runs after the choco package is installed

$CSCRIPT =  Join-Path $env:SYSTEMROOT   'System32\cscript.exe'
$OSPP_VBS = Join-Path $env:PROGRAMFILES 'Microsoft Office\Office16\OSPP.VBS'
$KMS_HOST = 'kms02.cit.cornell.edu'

Start-Process -NoNewWindow -Wait -FilePath $CSCRIPT -ArgumentList "`"$OSPP_VBS`" /sethst:$KMS_HOST"
Start-Process -NoNewWindow -Wait -FilePath $CSCRIPT -ArgumentList "`"$OSPP_VBS`" /act"
