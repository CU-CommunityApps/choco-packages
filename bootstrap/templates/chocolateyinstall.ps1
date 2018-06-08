$ErrorActionPreference = 'Stop'
Import-Module 'powershell-yaml'

# Initialize list of packages, if needed
if (-Not (Test-Path Env:CHOCO_INSTALLED_PACKAGES)) {
    Write-Output "Creating CHOCO_INSTALLED_PACKAGES Environment Variable"
    $Env:CHOCO_INSTALLED_PACKAGES = 'choco'
}

$CHOCO =        [io.path]::combine($Env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
$REG =          [io.path]::combine($Env:SYSTEMROOT, 'System32', 'reg.exe')
$USER_DIR =     Join-Path $Env:SYSTEMDRIVE 'Users'
$DEFAULT_HIVE = [io.path]::combine($USER_DIR, 'Default', 'NTUSER.DAT')
$STARTUP =      [io.path]::combine($Env:ALLUSERSPROFILE, 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'StartUp', '*')

$TOOLS_DIR =    $PSScriptRoot
$CONFIG =       Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.json') | ConvertFrom-Json
$INSTALL_DIR =  Join-Path $Env:TEMP $CONFIG.Id
$SECRETS_FILE = Join-Path $INSTALL_DIR 'secrets.yml'
$S3_URI =       "https://s3.amazonaws.com/$($Env:CHOCO_BUCKET)/packages/$($CONFIG.Id).zip"
$INSTALLED =    $Env:CHOCO_INSTALLED_PACKAGES.Split(';')

# Check if current package is already installed
if ($INSTALLED.Contains($CONFIG.Id)) {
    Write-Output "$($CONFIG.Id) Already Installed"
    Exit
}

# Make useful directories available to the environment
[Environment]::SetEnvironmentVariable('INSTALL_DIR', $INSTALL_DIR, 'Process')
[Environment]::SetEnvironmentVariable('TOOLS_DIR', $TOOLS_DIR, 'Process')

# Always Run Preinstall PowerShell script
Write-Output        "Running preinstall.ps1..."
Invoke-Expression   $(Join-Path "$TOOLS_DIR" 'preinstall.ps1')

##############################################
################# Env Vars ###################
##############################################
Function EnvVars {

    # Set all Environment Variables listed in config
    $envVars = ($CONFIG.Environment | Get-Member -MemberType NoteProperty).Name
    foreach ($envVar in $envVars) {
        $envValue = [Environment]::ExpandEnvironmentVariables($CONFIG.Environment.$envVar).Replace('%%', '%')

        if (Test-Path Env:$envVar) {
            $envValue = "$envValue;$([Environment]::GetEnvironmentVariable($envVar))"
        }

        Write-Output "Setting Environment Variable $envVar to $envValue)"
        [Environment]::SetEnvironmentVariable($envVar, $CONFIG.Environment.$envVar, 'Machine')
    }
}

##############################################
################ Choco Packs #################
##############################################
Function Choco {

    # Install any listed Choco Gallery packages
    foreach ($chocoPackage in $CONFIG.ChocoPackages) {
        Write-Output "Installing Choco Package $chocoPackage"

        Start-Process `
            -FilePath "$CHOCO" `
            -ArgumentList "install $chocoPackage --no-progress -r -y" `
            -NoNewWindow -Wait
    }
}

##############################################
################ Installers ##################
##############################################
Function Installers {

    # Install the Packaged Application, if there is one
    $install = $CONFIG.Install
    if ($install) {

        # Download and extract ZIP from S3
        Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
        Install-ChocolateyZipPackage `
            -PackageName "$($CONFIG.Id)" `
            -UnzipLocation "$INSTALL_DIR" `
            -Url "$S3_URI" 

        # Put any secrets into the environment
        if (Test-Path $SECRETS_FILE) {
            $secrets = Get-Content -Raw -Path "$SECRETS_FILE" | ConvertFrom-Yaml

            foreach ($secret in $secrets) {
                [Environment]::SetEnvironmentVariable("$secret", "$($secrets.$secret)", 'Process')
            }
        }

        # Run Preinstall PowerShell script
        Write-Output        "Running preinstall.ps1..."
        Invoke-Expression   $(Join-Path $TOOLS_DIR 'preinstall.ps1')

        # Install each installer file
        $install | % {

            # Expand environment variables in relevant vars
            $installerFile = [Environment]::ExpandEnvironmentVariables($_.File).Replace('%%', '%')
            $silentArgs = [Environment]::ExpandEnvironmentVariables($_.Arguments).Replace('%%', '%')

            # Prepare Choco Install Args from config
            $packageArgs = @{
                packageName="$($CONFIG.Id)"
                fileType="$($_.FileType)"
                file="$installerFile"
                silentArgs="$silentArgs"
                validExitCodes=$_.ExitCodes
            }

            # Run the Choco Install
            Write-Output "Installing $($CONFIG.Id) With Args: $($packageArgs | Out-String)"
            Install-ChocolateyInstallPackage @packageArgs
        }
    }
}

##############################################
##################### S3 #####################
##############################################
Function S3 {
    
    $file = "$INSTALL_DIR\$($CONFIG.Id).zip"
    iwr -Uri $S3_URI -OutFile $file

    # Unzip the file to specified location
    $shell = new-object -com shell.application 
    $zip_file = $shell.namespace($file) 
    $destination = $shell.namespace($INSTALL_DIR) 
    $destination.Copyhere($zip_file.items())

    <#
    # Download and extract ZIP from S3
    Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
    Install-ChocolateyZipPackage `
        -PackageName "$($CONFIG.Id)" `
        -UnzipLocation "$INSTALL_DIR" `
        -Url "$S3_URI" 
    #>

    # Put any secrets into the environment
    if (Test-Path $SECRETS_FILE) {
        $secrets = Get-Content -Raw -Path "$SECRETS_FILE" | ConvertFrom-Yaml

        foreach ($secret in $secrets) {
            [Environment]::SetEnvironmentVariable("$secret", "$($secrets.$secret)", 'Process')
        }
    }

    # Run Preinstall PowerShell script
        Write-Output        "Running preinstall.ps1..."
        Invoke-Expression   $(Join-Path $TOOLS_DIR 'preinstall.ps1')

}

##############################################
############## Registry Files ################
##############################################
Function Registry {
    
    # Set all the Registry Keys listed in config

    $hives = ($CONFIG.Registry | Get-Member -MemberType NoteProperty).Name
    foreach ($hive in $hives) {
        $regKeys = ($CONFIG.Registry.$hive | Get-Member -MemberType NoteProperty).Name

        # Do we care?
        if ($regKeys.Count -eq 0) { 
            Write-Output "No Registry Keys to set for $hive"
            continue 
        }

        # Load Default User
        if ($hive -eq 'HKUD') {
            Start-Process `
                -ArgumentList "LOAD HKU\DefaultUser $DEFAULT_HIVE" `
                -FilePath "$REG" `
                -NoNewWindow -Wait 

            if (!(Test-Path 'HKUD:\')) {
                New-PSDrive `
                    -Name 'HKUD' `
                    -PSProvider 'Registry' `
                    -Root 'HKEY_USERS\DefaultUser'
            }
        }

        # Make sure abbreviated drives exist for all standard Registry Hives
        if (($hive -eq 'HKCC') -and (!(Test-Path 'HKCC:\'))) {
            New-PSDrive `
                -Name 'HKCC' `
                -PSProvider 'Registry' `
                -Root 'HKEY_CURRENT_CONFIG'
        }

        if (($hive -eq 'HKCR') -and (!(Test-Path 'HKCR:\'))) {
            New-PSDrive `
                -Name 'HKCR' `
                -PSProvider 'Registry' `
                -Root 'HKEY_CLASSES_ROOT'
        }

        if (($hive -eq 'HKCU') -and (!(Test-Path 'HKCU:\'))) {
            New-PSDrive `
                -Name 'HKCU' `
                -PSProvider 'Registry' `
                -Root 'HKEY_CURRENT_USER'
        }

        if (($hive -eq 'HKLM') -and (!(Test-Path 'HKLM:\'))) {
            New-PSDrive `
                -Name 'HKLM' `
                -PSProvider 'Registry' `
                -Root 'HKEY_LOCAL_MACHINE'
        }

        if (($hive -eq 'HKU') -and (!(Test-Path 'HKU:\'))) {
            New-PSDrive `
                -Name 'HKU' `
                -PSProvider 'Registry' `
                -Root 'HKEY_USERS'
        }

        Write-Output "Setting Registry Keys for $hive..."
        foreach ($regKey in $regKeys) {
            $regProperties = ($CONFIG.Registry.$hive.$regKey | Get-Member -MemberType NoteProperty).Name
            $regKeyExpanded = [Environment]::ExpandEnvironmentVariables($regKey).Replace('%%', '%')
            $regKeyPath = "$($hive):\$regKeyExpanded"

            Write-Output "Creating Registry Key $regKeyPath"
            New-Item -Path "$regKeyPath" -Force 

            foreach ($regProperty in $regProperties) {
                $regItem = $CONFIG.Registry.$hive.$regKey.$regProperty
                $regValue = [Environment]::ExpandEnvironmentVariables($regItem.Value).Replace('%%', '%')

                Write-Output "Setting Registry Property $regProperty to $regValue"
                New-ItemProperty `
                    -Name "$regProperty" `
                    -Path "$regKeyPath" `
                    -PropertyType "$($regItem.Type)" `
                    -Value "$($regItem.Value)" `
                    -Force
            }
        }

        if ($hive -eq 'HKUD') {
            Start-Process `
                -FilePath "$REG" `
                -ArgumentList "UNLOAD HKU\DefaultUser" `
                -NoNewWindow -Wait 
        }
    }

}


##############################################
################### Files ####################
##############################################
Function Files {

    # Put all static files into the filesystem
    $files = ($CONFIG.Files | Get-Member -MemberType NoteProperty).Name
    foreach($file in $files) {
        $sourcePath = [Environment]::ExpandEnvironmentVariables("$file")
        $destPath = [Environment]::ExpandEnvironmentVariables("$($CONFIG.Files.$file)")

        Write-Output "Copying $sourcePath to $destPath"

        New-Item `
            -Path $(Split-Path -Path "$destPath") `
            -ItemType "Directory" `
            -Force

        Copy-Item `
            -Path "$sourcePath" `
            -Destination "$destPath" `
            -Force -Recurse
    }

}

##############################################
################# Services ###################
##############################################
Function Services {

    # Set all Windows Services listed in config
    $services = ($CONFIG.Services | Get-Member -MemberType NoteProperty).Name
    foreach ($service in $services) {
        Write-Output "Setting Service $service to Startup Type $($CONFIG.Services.$service)"
        Set-Service `
            -Name "$service" `
            -StartupType "$($CONFIG.Services.$service)"
    }
}

##############################################
################# SchedTask ##################
##############################################
Function SchedTask {

    # Create all Scheduled Tasks listed in config
    foreach ($scheduledTask in $CONFIG.ScheduledTasks) {
        Write-Output "Creating Scheduled Task $scheduledTask"

        $taskConfig = Join-Path "$TOOLS_DIR" "$($scheduledTask).xml"
        Register-ScheduledTask `
            -TaskName "$scheduledTask" `
            -Xml (Get-Content "$taskConfig" | Out-String)
    }
}

# Only run config.yml sections if specified
If ($CONFIG.Environment){EnvVars}
If ($CONFIG.ChocoPackages){Choco}
If ($CONFIG.Install){Installers}
If (!($CONFIG.Install)){S3}
If ($CONFIG.Registry){Registry}
If ($CONFIG.Files){Files}
If ($CONFIG.Services){Services}
If ($CONFIG.ScheduledTasks){SchedTask}

# Run Postinstall PowerShell script
Write-Output "Running postinstall.ps1..."
Invoke-Expression $(Join-Path "$TOOLS_DIR" 'postinstall.ps1')

# Remove any files that might have been added to the Startup directory
Write-Output "Removing any startup files"
Remove-Item -Recurse -Force "$STARTUP"

# Remove all installation files from disk
if (Test-Path $INSTALL_DIR) {
    Write-Output "Removing Installer Files..."
    Remove-Item -Recurse -Force "$INSTALL_DIR"
}

# Update environment to list this package as installed
$INSTALLED += $CONFIG.Id
$INSTALLED = $INSTALLED -Join ';'
[Environment]::SetEnvironmentVariable('CHOCO_INSTALLED_PACKAGES', $INSTALLED, 'Machine')

Write-Output "$($CONFIG.Id) Install Complete!"
