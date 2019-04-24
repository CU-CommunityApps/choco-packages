# Runs after the choco package is installed
$custExperience = "$env:ProgramFiles\Autodesk\AutoCAD 2020\AcExperience.arx"
If (Test-Path $custExperience){Remove-Item $custExperience -Force}