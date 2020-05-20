[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download and install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Add choco.exe to user path
$env:Path += "$env:ALLUSERSPROFILE\chocolatey\bin"

# Install git
Invoke-Expression "choco.exe install -y git"

# Install Docker
Install-Module DockerMsftProvider -Force
Install-Package Docker -ProviderName DockerMsftProvider -Force

# Install AWS CLI v2
Start-BitsTransfer -Source "https://d1vvhvl2y92vvt.cloudfront.net/AWSCLIV2.msi" -Destination "$env:USERPROFILE\Downloads"
Start-Process msiexec -ArgumentList "/i $env:USERPROFILE\Downloads\AWSCLIV2.msi /qb" -Wait

# Add aws cli to $PATH
$env:Path += "$env:ProgramFiles\Amazon\AWSCLIV2"

# Restart
Restart-Computer -Force