# Cornell Chocolatey Framework Bootstrap Entry

$BOOTSTRAP =    Join-Path $env:SYSTEMROOT 'Temp\choco-bootstrap'
$CHOCO =        Join-Path $env:ALLUSERSPROFILE 'chocolatey\bin\choco.exe'
$PSEXEC =       Join-Path $env:ALLUSERSPROFILE 'chocolatey\bin\PsExec.exe'
$GIT =          Join-Path $env:PROGRAMFILES '\Git\bin\git.exe'
$PYTHON =       Join-Path $env:SYSTEMDRIVE 'Python36\python.exe'
$PIP =          Join-Path $env:SYSTEMDRIVE 'Python36\Scripts\pip.exe'

$REPO =         'https://github.com/CU-CommunityApps/choco-packages.git'
$PREREQS =      'git sysinternals'
$PYVERSION =    '3.6.3'
$PYDEPENDS =    'boto3 pyyaml'

# Create Bootstrap Directory
New-Item -ItemType Directory -Force -Path $BOOTSTRAP
Set-Location $BOOTSTRAP

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git plus prerequisites and Clone the Choco Respository
Start-Process -NoNewWindow -Wait -FilePath $CHOCO  -ArgumentList "install $PREREQS -r -y"
Start-Process -NoNewWindow -Wait -FilePath $GIT    -ArgumentList "clone $REPO .\choco-packages"

# Install Python and Dependencies
Start-Process -NoNewWindow -Wait -FilePath $CHOCO  -ArgumentList "install python --version $PYVERSION -r -y"
Start-Process -NoNewWindow -Wait -FilePath $PIP    -ArgumentList "-q install $PYDEPENDS"

# Escape from PowerShell!
Start-Process -NoNewWindow -Wait -FilePath $PSEXEC -ArgumentList "-w $BOOTSTRAP -i -s $PYTHON .\choco-packages\bootstrap\bootstrap.py"

