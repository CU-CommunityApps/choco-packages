Write-Output "Setting ATR settings..."
$path = (gci "${env:ProgramFiles}\Tableau" -Include atrdiag.exe -Recurse -ErrorAction SilentlyContinue).DirectoryName
Start-Process "$path\atrdiag.exe" -ArgumentList "-enableATRFeature"
Start-Process "$path\atrdiag.exe" -ArgumentList "-setDuration 57600"
