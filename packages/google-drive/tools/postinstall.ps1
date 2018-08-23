# Runs after the choco package is installed
Start-Process "$env:windir\system32\rundll32.exe" -ArgumentList "advpack.dll,LaunchINFSectionEx `"$env:PROGRAMFILES\Google\Drive File Stream\Drivers\2356\googledrivefs2356.inf`",,,4"
Start-Sleep -s 10
Start-Process regsvr32 -ArgumentList "`"C:\Program Files\Google\Drive File Stream\25.252.303.31\drivefsext.dll`" /s"
Start-Sleep -s 10

