$ErrorActionPreference = 'Stop'

# Cornell Chocolatey Framework Automated Bootstrap Entry

if (Test-Path Env:CHOCO_INSTALL_COMPLETE) {
    Exit
}

$INSTALL_ARGS = $args -Join ' '
$BOOTSTRAP =    [io.path]::combine($Env:SYSTEMROOT, 'Temp', 'choco-bootstrap')
$PACKAGES =     [io.path]::combine($BOOTSTRAP, 'choco-packages')
$CHOCO =        [io.path]::combine($Env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$CHOCOLOG =     [io.path]::combine($Env:ALLUSERSPROFILE, 'choco-bootstrap.log')
$PSEXEC =       [io.path]::combine($Env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'PsExec.exe')
$GIT =          [io.path]::combine($Env:PROGRAMFILES, 'Git', 'bin', 'git.exe')

$PYBOOTSTRAP =  [io.path]::combine($BOOTSTRAP, 'choco-packages', 'bootstrap', 'bootstrap.py')
$PYDIR =        Join-Path $Env:SYSTEMDRIVE 'Python36'
$PYTHON =       Join-Path $PYDIR 'python.exe'
$PIP =          [io.path]::combine($PYDIR, 'Scripts', 'pip.exe')

$REPO =         'https://github.com/CU-CommunityApps/choco-packages.git'
$BRANCH =       "$($args[0])"
$PREREQS =      'git sysinternals powershell'
$PYVERSION =    '3.6.4'
$PYDEPENDS =    'boto3 pyyaml'

if (-Not (Test-Path Env:CHOCO_BOOTSTRAP_COMPLETE)) {

    # Create Bootstrap Directory
    New-Item -ItemType Directory -Force -Path $BOOTSTRAP | Tee-Object -Append -FilePath $CHOCOLOG
    Set-Location $BOOTSTRAP

    # Install Chocolatey
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) `
    | Tee-Object -Append -FilePath $CHOCOLOG

    # Install Git, Sysinternals and PowerShell 5.x 
    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install $PREREQS --no-progress -r -y" `
        -NoNewWindow -Wait `
    | Tee-Object -Append -FilePath $CHOCOLOG

    # Clone the Choco Respository
    Start-Process `
        -FilePath $GIT `
        -ArgumentList "clone -b $BRANCH $REPO $PACKAGES" `
        -NoNewWindow -Wait `
    | Tee-Object -Append -FilePath $CHOCOLOG

    <# # Checkout the Selected Branch
    Start-Process `
        -FilePath $GIT `
        -ArgumentList "checkout $BRANCH" `
        -WorkingDirectory "$PACKAGES" `
        -NoNewWindow -Wait `
    | Tee-Object -Append -FilePath $CHOCOLOG
    #>

    # Install Python
    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install python --version $PYVERSION --no-progress -r -y" `
        -NoNewWindow -Wait `
    | Tee-Object -Append -FilePath $CHOCOLOG

    # Install Python Dependencies
    Start-Process `
        -FilePath $PIP `
        -ArgumentList "-q install $PYDEPENDS" `
        -NoNewWindow -Wait `
    | Tee-Object -Append -FilePath $CHOCOLOG

    # Run Python Bootstrap to notify Step Functions
    Start-Process `
        -FilePath $PSEXEC `
        -ArgumentList "-w $BOOTSTRAP -i -s $PYTHON $PYBOOTSTRAP bootstrap $INSTALL_ARGS"

    [Environment]::SetEnvironmentVariable('CHOCO_BOOTSTRAP_COMPLETE', '1', 'Machine')

}

elseif (-Not (Test-Path Env:CHOCO_INSTALL_COMPLETE)) {

    # Install PowerShell Modules
    Install-PackageProvider -Name 'NuGet' -Force `
    | Tee-Object -Append -FilePath $CHOCOLOG

    Install-Module 'powershell-yaml' -Force `
    | Tee-Object -Append -FilePath $CHOCOLOG

    # Run Python Bootstrap via Sysinternals PsExec to enable GUI installs in the SYSTEM context
    Start-Process `
        -FilePath $PSEXEC `
        -ArgumentList "-w $BOOTSTRAP -i -s $PYTHON $PYBOOTSTRAP install $INSTALL_ARGS" `

    [Environment]::SetEnvironmentVariable('CHOCO_INSTALL_COMPLETE', '1', 'Machine')

}

