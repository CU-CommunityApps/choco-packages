# Runs before the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer' 

#Start-Process -FilePath "$INSTALL_DIR\odbcsql.bat" -WindowStyle Hidden
 
#Copy-Item "$env:INSTALL_DIR\startbaja.cmd" "%PROGRAMFILES%\SOLIDWORKS PDM\startbaja.cmd"
#gci -Path $INSTALL_DIR\Microsoft* -Filter *.exe -Recurse | % {Start-Process $_.FullName -ArgumentList "/q /norestart" -wait -Verbose}
