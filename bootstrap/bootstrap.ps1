$ErrorActionPreference = 'Stop'

# Cornell Chocolatey Framework Bootstrap Entry

if (Test-Path env:CHOCO_INSTALL_COMPLETE) {
    Exit
}

$BOOTSTRAP =    [io.path]::combine($env:SYSTEMROOT, 'Temp', 'choco-bootstrap')
$PACKAGES =     [io.path]::combine($BOOTSTRAP, 'choco-packages')
$CHOCO =        [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$CHOCOLOG =     [io.path]::combind($env:ALLUSERSPROFILE, 'choco-bootstrap.log')
$PSEXEC =       [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'PsExec.exe')
$GIT =          [io.path]::combine($env:PROGRAMFILES, 'Git', 'bin', 'git.exe')

$PYBOOTSTRAP =  [io.path]::combine($BOOTSTRAP, 'choco-packages', 'bootstrap', 'bootstrap.py')
$PYDIR =        Join-Path $env:SYSTEMDRIVE 'Python36'
$PYTHON =       Join-Path $PYDIR 'python.exe'
$PIP =          [io.path]::combine($PYDIR, 'Scripts', 'pip.exe')

$REPO =         'https://github.com/marty-sullivan/choco-packages.git'
$PREREQS =      'git sysinternals powershell'
$PYVERSION =    '3.6.4'
$PYDEPENDS =    'boto3 pyyaml'

if (-Not (Test-Path env:CHOCO_BOOTSTRAP_COMPLETE)) {

    # Create Bootstrap Directory
    New-Item -ItemType Directory -Force -Path $BOOTSTRAP | Tee-Object -Append -FilePath $CHOCOLOG
    Set-Location $BOOTSTRAP

    # Install Chocolatey
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Tee-Object -Append -FilePath $CHOCOLOG

    # Install Git, Sysinternals and PowerShell 5.x 
    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install $PREREQS --no-progress -r -y" `
        -NoNewWindow -Wait | Tee-Object -Append -FilePath $CHOCOLOG

    # Clone the Choco Respository
    Start-Process `
        -FilePath $GIT `
        -ArgumentList "clone $REPO $PACKAGES" `
        -NoNewWindow -Wait | Tee-Object -Append -FilePath $CHOCOLOG

    # Install Python
    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install python --version $PYVERSION --no-progress -r -y" `
        -NoNewWindow -Wait | Tee-Object -Append -FilePath $CHOCOLOG

    # Install Python Dependencies
    Start-Process `
        -FilePath $PIP `
        -ArgumentList "-q install $PYDEPENDS" `
        -NoNewWindow -Wait | Tee-Object -Append -FilePath $CHOCOLOG

    [Environment]::SetEnvironmentVariable('CHOCO_BOOTSTRAP_COMPLETE', '1', 'Machine')
    Restart-Computer -Force

}

elseif (-Not (Test-Path env:CHOCO_INSTALL_COMPLETE)) {

    # Install PowerShell Modules
    Install-PackageProvider -Name 'NuGet' -Force | Tee-Object -Append -FilePath $CHOCOLOG
    Install-Module 'powershell-yaml' -Force | Tee-Object -Append -FilePath $CHOCOLOG

    # Run Python Bootstrap via Sysinternals PsExec to enable GUI installs in the SYSTEM context
    Start-Process `
        -FilePath $PSEXEC `
        -ArgumentList "-w $BOOTSTRAP -i -s $PYTHON $PYBOOTSTRAP" `
        -NoNewWindow -Wait

    [Environment]::SetEnvironmentVariable('CHOCO_INSTALL_COMPLETE', '1', 'Machine')
    Restart-Computer -Force

}

