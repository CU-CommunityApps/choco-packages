# Startup script for suppressing SolidWorks prompts
# Run as scheduled task at every login?

# SolidWorks 2017
$solid = "Registry::\HKCU\Software\SolidWorks\SolidWorks 2018\Security"
If (!(Test-Path $solid)){New-Item -Path $solid -force}
New-ItemProperty -Path $solid -Name "EULA Accepted 2018 SP4.0 $env:ComputerName $env:UserName" -Value "Yes" -PropertyType "string" -force

# Composer
$3dComposer = "Registry::\HKCU\Software\Dassault Systemes\3DVIAComposer\7.4\Preferences"
If (!(Test-Path $3dComposer)){New-Item -Path $3dComposer -force}
New-ItemProperty -Path $3dComposer -Name "EulaAccepted 2017 SP3.0 $env:ComputerName $env:UserName" -Value "1" -PropertyType "DWORD" -Force

$composer = "Registry::\HKCU\Software\Dassault Systemes\Composer\7.5\Preferences"
If (!(Test-Path $composer)){New-Item -Path $composer -force}
New-ItemProperty -Path $composer -Name "EulaAccepted 2018 SP4.0 $env:ComputerName $env:UserName" -Value "1" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "EulaAccepted 2018 7.5.5.1346 $env:ComputerName $env:Username" -Value "1" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "RefreshProgressUI" -Value "1" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "EulaAccepted" -Value "0" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "Composer.EulaAccepted" -Value "0" -PropertyType "DWORD" -Force
New-ItemProperty -Path $composer -Name "Sync.EulaAccepted" -Value "0" -PropertyType "DWORD" -Force

# eDrawings
$eDraw = "Registry::\HKCU\Software\eDrawings\e2018\General"
If (!(Test-Path $eDraw)){New-Item -Path $eDraw -force}
New-ItemProperty -Path $eDraw -Name "ShowLicense 2018 sp04 $env:ComputerName $env:UserName" -Value "0" -PropertyType "DWORD" -Force

# CosmosWorks
$cosmosPath = "Registry::\HKCU\Software\srac"
If (!(Test-Path $cosmosPath)){New-Item -Path $cosmosPath -force}

# Ugh for forward flash...
(Get-Item HKCU:\).OpenSubKey("Software\srac",$true).CreateSubKey("Cosmos/Works\COSMOSWorks 2018\Current Version").Close()
If ($? -eq $true){New-ItemProperty -Path "Registry::\HKCU\Software\srac\Cosmos/Works\COSMOSWorks 2018\Current Version" -Name "EULA Accepted 2018 SP4.0 $env:ComputerName $env:UserName" -Value "Yes" -PropertyType "string" -Force}
