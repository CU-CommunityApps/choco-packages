# Tableau licensing process

# Make sure time is set properly
If ((gp HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation).TimeZoneKeyName -match "Eastern Standard Time"){Restart-Service -Name W32Time}
Else {New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation -Name "TimeZoneKeyName" -PropertyType "String" -Value "Eastern Standard Time" -Force; Restart-Service -Name W32Time}

# Check Licensing service status
If ((Get-Service -Name 'FlexNet Licensing Service 64').Status -ne "Running"){Start-Service -Name 'FlexNet Licensing Service 64'}
