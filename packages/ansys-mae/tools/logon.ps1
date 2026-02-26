# Logon Script

# Get hostname
$hostname = $env:COMPUTERNAME

# Config files
$config_files = "$env:UserProfile\Documents\Ansoft\ElectronicsDesktop2025.2\config"

# Update XML Contents as logged on user
Do {
    Write-Output "Waiting for $env:UserName home directory creation"
}Until(Test-Path $config_files)

# Rename config files
gci -Path $config_files "host*" | % { Rename-Item $_.FullName $_.FullName.Replace("host", $hostname) }

# Update XML contents
(Get-Content "$($config_files)\$($hostname)_user.XML").replace("replace_user", "$($hostname)_user") | Set-Content "$($config_files)\$($hostname)_user.XML"
(Get-Content "$($config_files)\$($hostname)_user.XML").replace("temp_username", "$env:UserName") | Set-Content "$($config_files)\$($hostname)_user.XML"
