$ErrorActionPreference = "Stop"

if (-Not (Test-Path env:CHOCO_INSTALLED_PACKAGES)) {
    Write-Output "Creating CHOCO_INSTALLED_PACKAGES Environment Variable"
    $env:CHOCO_INSTALLED_PACKAGES = 'choco'
}

$CHOCO =        [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$REG =          [io.path]::combine($env:SYSTEMROOT, 'System32', 'reg.exe')
$USER_DIR =     Join-Path $env:SYSTEMDRIVE 'Users'
$DEFAULT_HIVE = [io.path]::combine($USER_DIR, 'Default', 'NTUSER.DAT')
$STARTUP =      [io.path]::combine($env:ALLUSERSPROFILE, 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'StartUp', '*')

$TOOLS_DIR =    $PSScriptRoot
$CONFIG =       Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.json') | ConvertFrom-Json
$INSTALL_DIR =  Join-Path $env:TEMP $CONFIG.Id
$S3_URI =       "https://s3.amazonaws.com/$($env:CHOCO_BUCKET)/packages/$($CONFIG.Id).zip"

$INSTALLED = $env:CHOCO_INSTALLED_PACKAGES.Split(';')
if ($INSTALLED.Contains($CONFIG.Id)) {
    Write-Output "$($CONFIG.Id) Already Installed"
    Exit
}

[Environment]::SetEnvironmentVariable('INSTALL_DIR', $INSTALL_DIR, 'PROCESS')
[Environment]::SetEnvironmentVariable('TOOLS_DIR', $TOOLS_DIR, 'PROCESS')

foreach ($chocoPackage in $CONFIG.ChocoPackages) {
    Write-Output "Installing Choco Package $chocoPackage"

    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install $chocoPackage --no-progress -r -y" `
        -NoNewWindow -Wait
}

$install = $CONFIG.Install
if ($install) {
    Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
    Install-ChocolateyZipPackage `
        -PackageName $CONFIG.Id `
        -UnzipLocation $INSTALL_DIR `
        -Url $S3_URI 

    Write-Output        "Running preinstall.ps1..."
    Invoke-Expression   $(Join-Path $TOOLS_DIR 'preinstall.ps1')

    $installerFile =    [Environment]::ExpandEnvironmentVariables($install.File)
    $silentArgs =       [Environment]::ExpandEnvironmentVariables($install.Arguments)

    $packageArgs = @{
        packageName=$CONFIG.Id
        fileType=$install.FileType
        file=$installerFile
        silentArgs=$silentArgs
        validExitCodes=$install.ExitCodes
    }

    Write-Output "Installing $($CONFIG.Id) With Args: $($packageArgs | Out-String)"
    Install-ChocolateyInstallPackage @packageArgs
}
else {
    Write-Output        "Running preinstall.ps1..."
    Invoke-Expression   $(Join-Path $TOOLS_DIR 'preinstall.ps1')
}

if (-Not (Test-Path 'HKCC:\')) {
    New-PSDrive `
        -Name 'HKCC' `
        -PSProvider 'Registry' `
        -Root 'HKEY_CURRENT_CONFIG'
}

if (-Not (Test-Path 'HKCR:\')) {
    New-PSDrive `
        -Name 'HKCR' `
        -PSProvider 'Registry' `
        -Root 'HKEY_CLASSES_ROOT'
}

if (-Not (Test-Path 'HKCU:\')) {
    New-PSDrive `
        -Name 'HKCR' `
        -PSProvider 'Registry' `
        -Root 'HKEY_CURRENT_USER'
}

if (-Not (Test-Path 'HKLM:\')) {
    New-PSDrive `
        -Name 'HKLM' `
        -PSProvider 'Registry' `
        -Root 'HKEY_LOCAL_MACHINE'
}

if (-Not (Test-Path 'HKU:\')) {
    New-PSDrive `
        -Name 'HKU' `
        -PSProvider 'Registry' `
        -Root 'HKEY_USERS'
}

$hives = ($CONFIG.Registry | Get-Member -MemberType NoteProperty).Name
foreach ($hive in $hives) {
    $regKeys = ($CONFIG.Registry.$hive | Get-Member -MemberType NoteProperty).Name

    if ($regKeys.Count -eq 0) { 
        Write-Output "No Registry Keys to set for $hive"
        continue 
    }

    if ($hive -eq 'HKUD') {
        Start-Process `
            -ArgumentList "LOAD HKU\DefaultUser $DEFAULT_HIVE" `
            -FilePath $REG `
            -NoNewWindow -Wait 

        if (-Not (Test-Path 'HKUD:\')) {
            New-PSDrive `
                -Name 'HKUD' `
                -PSProvider 'Registry' `
                -Root 'HKU:\DefaultUser'
        }
    }

    Write-Output "Setting Registry Keys for $hive..."
    foreach ($regKey in $regKeys) {
        $regProperties = ($CONFIG.Registry.$hive.$regKey | Get-Member -MemberType NoteProperty).Name
        $regKeyPath = "$($hive):\$regKey"

        Write-Output "Creating Registry Key $regKeyPath"
        New-Item -Path $regKeyPath -Force 

        foreach ($regProperty in $regProperties) {
            $regItem = $CONFIG.Registry.$hive.$regKey.$regProperty

            Write-Output "Setting Registry Property $regProperty to $($regItem.Value)"
            New-ItemProperty `
                -Name $regProperty `
                -Path $regKeyPath `
                -PropertyType $regItem.Type `
                -Value $regItem.Value `
                -Force
        }
    }

    if ($hive -eq 'HKUD') {
        Start-Process `
            -FilePath $REG `
            -ArgumentList "UNLOAD HKU\DefaultUser" `
            -NoNewWindow -Wait 
    }
}

$envVars = ($CONFIG.Environment | Get-Member -MemberType NoteProperty).Name
foreach ($envVar in $envVars) {
    Write-Output "Setting Environment Variable $envVar to $($CONFIG.Environment.$envVar)"
    [Environment]::SetEnvironmentVariable($envVar, $CONFIG.Environment.$envVar, 'Machine')
}

$services = ($CONFIG.Services | Get-Member -MemberType NoteProperty).Name
foreach ($service in $services) {
    Write-Output "Setting Service $service to Startup Type $($CONFIG.Services.$service)"
    Set-Service `
        -Name $service `
        -StartupType $CONFIG.Services.$service
}

foreach ($scheduledTask in $CONFIG.ScheduledTasks) {
    Write-Output "Creating Scheduled Task $scheduledTask"

    $taskConfig = Join-Path $TOOLS_DIR "$($scheduledTask).xml"
    Register-ScheduledTask `
        -TaskName $scheduledTask `
        -Xml (Get-Content $taskConfig | Out-String)
}

Write-Output "Running postinstall.ps1..."
Invoke-Expression $(Join-Path $TOOLS_DIR 'postinstall.ps1')

Write-Output "Removing any startup files"
Remove-Item -Recurse -Force $STARTUP

if (Test-Path $INSTALL_DIR) {
    Write-Output "Removing Installer Files..."
    Remove-Item -Recurse -Force $INSTALL_DIR
}

$INSTALLED += $CONFIG.Id
$INSTALLED = $INSTALLED -Join ';'
[Environment]::SetEnvironmentVariable('CHOCO_INSTALLED_PACKAGES', $INSTALLED, 'Machine')

Write-Output "$($CONFIG.Id) Install Complete!"

