# Runs after the choco package is installed
$custExperience = "$env:ProgramFiles\Autodesk\AutoCAD 2019\AcExperience.arx"
If (Test-Path $custExperience){Remove-Item $custExperience -Force}
