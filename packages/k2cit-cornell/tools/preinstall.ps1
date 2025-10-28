# Runs before the choco package is installed

#New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name "AoD_Combo" -Value '%AppStream_UserName%.%AppStream_Resource_Name%' -PropertyType ExpandString -Force
