# Cornell Chocolatey Framework Bootstrap Entry

# Create Temporary Directory
$BOOTSTRAP_DIRECTORY = Join-Path $env:SYSTEMROOT 'Temp\choco-bootstrap'
New-Item -ItemType Directory -Force -Path $BOOTSTRAP_DIRECTORY
Set-Location $BOOTSTRAP_DIRECTORY

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Tee-Object -Append -FilePath '.\bootstrap.log'

# Install Git and Clone the Choco Respository
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\choco.exe' -ArgumentList 'install git -y' | Tee-Object -Append -FilePath '.\bootstrap.log'
Start-Process -NoNewWindow -Wait -FilePath 'C:\Program Files\Git\bin\git.exe'        -ArgumentList 'clone https://github.com/CU-CommunityApps/choco-packages.git .\choco-packages' | Tee-Object -Append -FilePath '.\bootstrap.log'

# Install Python and Dependencies
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\choco.exe' -ArgumentList 'install python --version 3.6.3 -y' | Tee-Object -Append -FilePath '.\bootstrap.log'
Start-Process -NoNewWindow -Wait -FilePath 'C:\Python36\Scripts\pip.exe'             -ArgumentList 'install boto3 pyyaml' | Tee-Object -Append -FilePath '.\bootstrap.log'

# Escape from PowerShell!
Start-Process -NoNewWindow -Wait -FilePath 'C:\Python36\python.exe'                  -ArgumentList '.\choco-packages\bootstrap\bootstrap.py' | Tee-Object -Append -FilePath '.\bootstrap.log'

