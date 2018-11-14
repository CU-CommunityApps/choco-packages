# Runs before the choco package is installed
<#
# Copy scripts folder to local machine
#Copy-item "$env:INSTALL_DIR\scripts" -Destination "$env:ProgramFiles\Tableau\Tableau 2018.1\bin\scripts" -Recurse

# Registry keys must exist prior to application installation, hence this...(dpk25)
$REG =          [io.path]::combine($Env:SYSTEMROOT, 'System32', 'reg.exe')
$USER_DIR =     Join-Path $Env:SYSTEMDRIVE 'Users'
$DEFAULT_HIVE = [io.path]::combine($USER_DIR, 'Default', 'NTUSER.DAT')
$path =         "HKUD:\Software\Tableau\Registration\Data"
$key =          "email"
$type =         "String"
$value =        "$env:TABLEAU_EMAIL"

# Load hive for default user settings
Start-Process -ArgumentList "LOAD HKU\DefaultUser $DEFAULT_HIVE" -FilePath "$REG" -NoNewWindow -Wait 
If (!(Test-Path 'HKUD:\')) {New-PSDrive -Name 'HKUD' -PSProvider 'Registry' -Root 'HKEY_USERS\DefaultUser'}

# Set registry values
If (!(Test-Path $path)){New-Item -Path $path -Force}
New-ItemProperty -Path $path -Name $key -PropertyType $type -Value $value -Force

# Unload hive for default user
Start-Process -FilePath "$REG" -ArgumentList "UNLOAD HKU\DefaultUser" -NoNewWindow -Wait
#>