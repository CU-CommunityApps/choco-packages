mkdir C:\temp -ErrorAction SilentlyContinue

Write-Host "Get current group policy settings"
gpupdate /target:computer /force /wait:-1

Write-Host "Ensuring SYSTEM has symlink privs"
$policyFile="C:\Temp\secpol_current.inf"

# export current group policy settings to file
secedit /export /cfg $policyFile

# read file contents for symlink privs
Select-String -Path $policyFile -Pattern 'secreatesymboliclinkprivilege' -CaseSensitive:$false

# output current token permissions
whoami /all | Out-File -FilePath 'C:\Temp\system-token.txt' -Encoding UTF8 -Force

# Pre install the ID Manager Component Test
Start-Process "$INSTALL_DIR\image\Installer.exe" -ArgumentList "--manifest $INSTALL_DIR\AdskIdentityManager-UCT-Installer\setup.xml --install_mode install --offline_mode --silent --trigger_point local"
