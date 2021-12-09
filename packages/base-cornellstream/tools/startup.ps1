# $SEARCH = 'firefox'
# $INSTALLED = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, UninstallString
# $INSTALLED += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString
# $RESULT = $INSTALLED | ?{ $_.DisplayName -ne $null } | Where-Object {$_.DisplayName -match $SEARCH } 
# if ($RESULT.uninstallstring -like "msiexec*") {
# $ARGS=(($RESULT.UninstallString -split ' ')[1] -replace '/I','/X ') + ' /q'
# Start-Process msiexec.exe -ArgumentList $ARGS -Wait
# } else {
# $UNINSTALL_COMMAND=(($RESULT.UninstallString -split '\"')[1])
# $UNINSTALL_ARGS=(($RESULT.UninstallString -split '\"')[2]) + ' /S'
# Start-Process $UNINSTALL_COMMAND -ArgumentList $UNINSTALL_ARGS -Wait
# }

# List of applications to remove
$app = "Firefox"

# Get uninstall info for each possible application
If (gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
gp | where {$_.DisplayName -match $app}){

   $install = gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
   gp | where {$_.DisplayName -match $app} | select DisplayName, InstallLocation, UninstallString
   
   Start-Process $install.UninstallString -ArgumentList "/S" -WorkingDirectory $install.InstallLocation -WindowStyle Hidden

}
