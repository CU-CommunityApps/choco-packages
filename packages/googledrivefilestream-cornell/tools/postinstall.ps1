# Runs after the choco package is installed
# Stop and disable updater services
Stop-Service gupdate -Force
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem -Force
Set-Service gupdatem -StartupType Disabled

#Rename GoogleUpdate
Rename-Item -Path "c:\program files (x86)\google\update\GoogleUpdate.exe" -NewName "GoogleUpdateno.no" 

Start-Sleep -s 30

# Kill all running Google Drive processes
If (Get-Process "GoogleDrive*"){Get-Process "GoogleDrive*" | Stop-Process}

Unregister-ScheduledTask GoogleUpdateTaskMachine* -Confirm:$false
Unregister-ScheduledTask GoogleUpdateTaskMachine* -Confirm:$false

Start-Sleep -s 30
