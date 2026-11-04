# Runs after the choco package is installed

# Stop any running processes
Stop-Process -Name keyacc32 -Force -ErrorAction SilentlyContinue

# Update user field as outlined by Support
$logonKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyAccess\Settings\logon'
if (-not (Test-Path $logonKey)) { New-Item -Path $logonKey -Force | Out-Null }
New-ItemProperty -Path $logonKey -Name 'user' -Value '%AppStream_UserName%.%AppStream_Resource_Name%' -PropertyType ExpandString -Force

# Remove any system specific values prior to sysprep
Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyAccess\Settings\pref' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyAccess\Settings\settings' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ALLUSERSPROFILE\KeyAccess" -Recurse -Force -ErrorAction SilentlyContinue


