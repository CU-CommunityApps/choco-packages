# Startup Script

# Get hostname
$hostname = $env:COMPUTERNAME

# Rename config files
$config_files = "$env:SystemDrive\Users\Default\Documents\Ansoft\ElectronicsDesktop2025.2\config"
gci -Path $config_files "host*" | % { Rename-Item $_.FullName $_.FullName.Replace("host", $hostname) }

# Update XML contents
(Get-Content "$($config_files)\$($hostname)_user.XML").replace("replace_user", "$($hostname)_user") | Set-Content "$($config_files)\$($hostname)_user.XML"
