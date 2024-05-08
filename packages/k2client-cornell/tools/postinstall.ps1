# Runs after the choco package is installed
 
# Stop the KeyAccess Service
#Doesn't appear to be needed with PROP_LAUNCH=0
#Stop-Service KeyAccess -Force -ErrorAction SilentlyContinue
 
#Set KeyAccess startup to Manual
Set-Service KeyAccess -startuptype Manual
 
# Remove any system specific values prior to sysprep
Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyAccess\Settings\pref' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Sevices\KeyAccess\Settings\settings' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ALLUSERSPROFILE\KeyAccess" -Recurse -Force -ErrorAction SilentlyContinue
