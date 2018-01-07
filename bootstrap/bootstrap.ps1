# Cornell Chocolatey Framework Bootstrap Entry

$BOOTSTRAP =    [io.path]::combine($env:SYSTEMROOT, 'Temp', 'choco-bootstrap')
$PACKAGES =     [io.path]::combine($BOOTSTRAP, 'choco-packages')
$CHOCO =        [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$PSEXEC =       [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'PsExec.exe')
$GIT =          [io.path]::combine($env:PROGRAMFILES, 'Git', 'bin', 'git.exe')

$PYBOOTSTRAP =  [io.path]::combine($BOOTSTRAP, 'choco-packages', 'bootstrap', 'bootstrap.py')
$PYDIR =        Join-Path $env:SYSTEMDRIVE 'Python36'
$PYTHON =       Join-Path $PYDIR 'python.exe'
$PIP =          [io.path]::combine($PYDIR, 'Scripts', 'pip.exe')

$REPO =         'https://github.com/marty-sullivan/choco-packages.git'
$PREREQS =      'git sysinternals'
$PYVERSION =    '3.6.4'
$PYDEPENDS =    'boto3 pyyaml'

# Create Bootstrap Directory
New-Item -ItemType Directory -Force -Path $BOOTSTRAP
Set-Location $BOOTSTRAP

# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git plus prerequisites and Clone the Choco Respository
Start-Process `
    -FilePath $CHOCO `
    -ArgumentList "install $PREREQS --no-progress -r -y" `
    -NoNewWindow -Wait

Start-Process `
    -FilePath $GIT `
    -ArgumentList "clone $REPO $PACKAGES" `
    -NoNewWindow -Wait

# Install Python and Dependencies
Start-Process `
    -FilePath $CHOCO `
    -ArgumentList "install python --version $PYVERSION --no-progress -r -y" `
    -NoNewWindow -Wait 

Start-Process `
    -FilePath $PIP `
    -ArgumentList "-q install $PYDEPENDS" `
    -NoNewWindow -Wait

# Escape from PowerShell!
Start-Process `
    -FilePath $PSEXEC `
    -ArgumentList "-w $BOOTSTRAP -i -s $PYTHON $PYBOOTSTRAP" `
    -NoNewWindow -Wait 

