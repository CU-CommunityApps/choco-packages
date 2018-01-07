$ErrorActionPreference = "Stop"

$CHOCO =        [io.path]::combine($env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$REG =          [io.path]::combine($env:SYSTEMROOT, 'System32', 'reg.exe')
$USER_DIR =     Join-Path $env:SYSTEMDRIVE 'Users'
$DEFAULT_HIVE = [io.path]::combine($USER_DIR, 'Default', 'NTUSER.DAT')

$TOOLS_DIR =    $PSScriptRoot
$CONFIG =       Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.json') | ConvertFrom-Json
$INSTALL_DIR =  Join-Path $env:TEMP $CONFIG.Id
$S3_URI =       "https://s3.amazonaws.com/$($env:CHOCO_BUCKET)/packages/$($CONFIG.Id).zip"

[Environment]::SetEnvironmentVariable('INSTALL_DIR', $INSTALL_DIR, 'PROCESS')
[Environment]::SetEnvironmentVariable('TOOLS_DIR', $TOOLS_DIR, 'PROCESS')

foreach ($chocoPackage in $CONFIG.ChocoPackages) {
    Write-Output "Installing Choco Package $chocoPackage"

    Start-Process `
        -FilePath $CHOCO `
        -ArgumentList "install $chocoPackage --no-progress -r -y" `
        -NoNewWindow -Wait
}

Write-Output        "Running preinstall.ps1..."
Invoke-Expression   $(Join-Path $TOOLS_DIR 'preinstall.ps1')

$install = $CONFIG.Install
if ($install) {
    Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
    Install-ChocolateyZipPackage `
        -PackageName $CONFIG.Id `
        -UnzipLocation $INSTALL_DIR `
        -Url $S3_URI 

    $installerFile =    [Environment]::ExpandEnvironmentVariables($install.Installer)
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

        New-PSDrive `
            -Name 'HKUD' `
            -PSProvider 'Registry' `
            -Root 'HKU:\DefaultUser'
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

foreach ($scheduledTask in $CONFIG.ScheduledTasks) {
    Write-Output "Creating Scheduled Task $scheduledTask"

    $taskConfig = Join-Path $TOOLS_DIR "$($scheduledTask).xml"
    Register-ScheduledTask `
        -TaskName $scheduledTask `
        -Xml (Get-Content $taskConfig | Out-String)
}

Write-Output "Running postinstall.ps1..."
Invoke-Expression $(Join-Path $TOOLS_DIR 'postinstall.ps1')

Write-Output "Removing Installer Files..."
Remove-Item -Recurse -Force $INSTALL_DIR

Write-Output "Install Complete!"

