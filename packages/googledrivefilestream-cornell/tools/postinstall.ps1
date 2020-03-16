# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F
Stop-Service gupdate
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem
Set-Service gupdatem -StartupType Disabled
