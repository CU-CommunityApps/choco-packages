# Cornell Chocolatey Framework Bootstrap Entry

# Create Temporary Directory
$BOOTSTRAP_DIRECTORY = Join-Path $env:SYSTEMROOT 'Temp\choco-bootstrap'
New-Item -ItemType Directory -Force -Path $BOOTSTRAP_DIRECTORY
Set-Location $BOOTSTRAP_DIRECTORY

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Sysinternals + Git and Clone the Choco Respository
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\choco.exe' -ArgumentList 'install git sysinternals -r -y'
Start-Process -NoNewWindow -Wait -FilePath 'C:\Program Files\Git\bin\git.exe'        -ArgumentList 'clone https://github.com/CU-CommunityApps/choco-packages.git .\choco-packages'

# Install Python and Dependencies
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\choco.exe' -ArgumentList 'install python --version 3.6.3 -r -y'
Start-Process -NoNewWindow -Wait -FilePath 'C:\Python36\Scripts\pip.exe'             -ArgumentList '-q install boto3 pyyaml'

# Escape from PowerShell!
Start-Process -NoNewWindow -Wait -FilePath 'C:\Python36\python.exe'                  -ArgumentList '.\choco-packages\bootstrap\bootstrap.py'

