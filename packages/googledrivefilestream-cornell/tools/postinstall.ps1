# Runs after the choco package is installed
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineUA" /F
SCHTASKS /DELETE /TN "GoogleUpdateTaskMachineCore" /F
SCHTASKS /DELETE /TN "GoogleDriveFileStream" /F
"C:\Program Files (x86)\Google\Update\GoogleUpdate.exe /uninstall" 
Rename-Item "C:\Program Files (x86)\Google\Update" -NewName noup
