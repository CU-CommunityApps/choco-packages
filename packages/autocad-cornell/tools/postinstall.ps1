# Runs after the choco package is installed

#Remove autocad desktop shortcut
Remove-Item "c:\users\public\desktop\AutoCAD 2025 - English.lnk"

New-Item -Path "HKCU:\Software\Autodesk" -Name "ODIS" -Force
New-ItemProperty -Path "HKCU:\Software\Autodesk\ODIS" -Name "DisableManualUpdateInstall" -Value 1 -PropertyType DWORD -Force
