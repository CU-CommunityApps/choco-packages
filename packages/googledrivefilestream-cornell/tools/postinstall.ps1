# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F
Stop-process -processname GoogleUpdate
"C:\Program Files (x86)\Google\Update\GoogleUpdate.exe /uninstall" 
Rename-Item "C:\Program Files (x86)\Google\Update" -NewName noup
