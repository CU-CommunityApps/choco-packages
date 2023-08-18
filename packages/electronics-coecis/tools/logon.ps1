# Logon Script

# Get hostname
$hostname = $env:COMPUTERNAME.ToLower()

# Config files
$config_files = "$env:UserProfile\Documents\Ansoft\ElectronicsDesktop2023.2\config"

# Update XML Contents as logged on user
Do {
    Write-Output "Waiting for $env:UserName home directory creation"
}Until(Test-Path $config_files)

(Get-Content "$($config_files)\$($hostname)_user.XML").replace("replace_username", "$env:UserName") | Set-Content "$($config_files)\$($hostname)_user.XML"
