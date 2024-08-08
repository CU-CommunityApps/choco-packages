New-Item -Path "HKCU:\Software\Autodesk" -Name "ODIS" -Force
New-ItemProperty -Path "HKCU:\Software\Autodesk\ODIS" -Name "DisableManualUpdateInstall" -Value 1 -PropertyType DWORD -Force
