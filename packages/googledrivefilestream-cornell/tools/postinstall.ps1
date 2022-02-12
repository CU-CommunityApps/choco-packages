# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F

# Stop and disable updater services
Stop-Service gupdate -Force
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem -Force
Set-Service gupdatem -StartupType Disabled

Rename GoogleUpdate
Rename-Item -Path "c:\program files (x86)\google\update\GoogleUpdate.exe" -NewName "GoogleUpdateno.no" 

# Rename .bat to .cmd
# Rename-Item -Path "c:\program files\google\drive file stream\launch.bat" -NewName "launch.cmd" 

Start-Sleep -s 10

# Kill all running Google Drive processes
If (Get-Process "GoogleDrive*"){Get-Process "GoogleDrive*" | Stop-Process}
