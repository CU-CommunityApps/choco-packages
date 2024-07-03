# Startup script for suppressing SolidWorks prompts
# Run as session script at login

# SolidWorks 2023
$solid = "Registry::\HKCU\Software\SolidWorks\SolidWorks 2024"
If (!(Test-Path $solid\Security)){New-Item -Path $solid\Security -force}
New-ItemProperty -Path $solid\Security -Name "EULA Accepted 2024 SP0.1 $env:ComputerName $env:UserName" -Value "Yes" -PropertyType "string" -force
# If (!(Test-Path $solid\General\DontAskAgainOptions)){New-Item -Path $solid\General\DontAskAgainOptions -force}
# New-ItemProperty -Path $solid\General\DontAskAgainOptions -Name "MSG_SHOW_WELCOME_DLG_AT_STARTUP%*^%$&9862" -Value "7" -PropertyType "DWORD" -force

$composer = "Registry::\HKCU\Software\Dassault Systemes\Composer\7.11\Preferences"
If (!(Test-Path $composer)){New-Item -Path $composer -force}
# Composer Player Popups
New-ItemProperty -Path $composer -Name "EulaAccepted" -Value "0" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "EulaAccepted 2024 7.11.2.24254 $env:ComputerName $env:Username" -Value "1" -PropertyType "DWORD" -Force
# Composer Popups
New-ItemProperty -Path $composer -Name "Composer.EulaAccepted" -Value "0" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "Composer.EulaAccepted 2024 2024 7.11.2.24254 $env:ComputerName $env:Username" -Value "1" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "RefreshProgressUI" -Value "1" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "Sync.EulaAccepted" -Value "0" -PropertyType "DWORD" -Force

# eDrawings
$eDraw = "Registry::\HKCU\Software\eDrawings\e2024\General"
If (!(Test-Path $eDraw)){New-Item -Path $eDraw -force}
New-ItemProperty -Path $eDraw -Name "ShowLicense 2024 sp0.1 $env:ComputerName $env:UserName" -Value "0" -PropertyType "DWORD" -Force
