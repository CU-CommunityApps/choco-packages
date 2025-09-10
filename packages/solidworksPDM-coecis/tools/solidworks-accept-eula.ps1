# Startup script for suppressing SolidWorks prompts
# Run as session script at login

# SolidWorks PDM 2025
$solid = "Registry::\HKCU\Software\Solidworks\Applications\PDMWorks Enterprise"
If (!(Test-Path $solid\Security)){New-Item -Path $solid\Security -force}
New-ItemProperty -Path $solid\Security -Name "EULA Accepted 2025 33 0 $env:ComputerName" -Value "Yes" -PropertyType "string" -force