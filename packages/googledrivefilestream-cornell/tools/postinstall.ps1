# Runs after the choco package is installed

#Start-Sleep -s 10

# Stop and disable updater services
Stop-Service gupdate -Force
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem -Force
Set-Service gupdatem -StartupType Disabled

# Kill all running Google Drive processes
If (Get-Process "GoogleDrive*"){Get-Process "GoogleDrive*" | Stop-Process}
