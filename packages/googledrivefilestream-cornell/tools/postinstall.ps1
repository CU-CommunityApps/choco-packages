# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F
Stop-process -processname GoogleUpdate
Rename-Item "C:\Program Files (x86)\Google\Update" -NewName noup
Stop-Service gupdate
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem
Set-Service gupdatem -StartupType Disabled
