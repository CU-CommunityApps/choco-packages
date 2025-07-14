# Runs after the choco package is installed

#Remove autocad desktop shortcut
Remove-Item "c:\users\public\desktop\AutoCAD 2026 - English.lnk"

#Set the Location to the registry
Set-Location -Path "HKCU:\Software"

#Create a new key
Get-Item -Path 'HKCU:\Software' | New-Item -Name "Autodesk\ODIS" -Force

#Create new items with values
New-ItemProperty -Path "HKCU:\Software\Autodesk\ODIS" -Name "DisableManualUpdateInstall" -Value 1 -PropertyType DWORD -Force
