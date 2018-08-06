[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false,Position=1,HelpMessage="Installation Mode - 't' (troubleshoot) or 'u' (uninstall)")]
    [ValidateNotNullOrEmpty()]
    [string]$mode,
    [Parameter(Mandatory=$false,Position=2,HelpMessage="Application")]
    [ValidateNotNullOrEmpty()]
    [string]$APP,
    [Parameter(Mandatory=$false,Position=3,HelpMessage="S3 Bucket Name")]
    [ValidateNotNullOrEmpty()]
    [string]$CHOCO_BUCKET

)

Function Main($TOOLS_DIR, $INSTALL_DIR, $CONFIG) {

    $ErrorActionPreference = 'Stop'
    Import-Module "powershell-yaml"

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

    If (!($TOOLS_DIR)){
        $TOOLS_DIR = $PSScriptRoot
        $CONFIG =   Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.json') | ConvertFrom-Json
        $INSTALL_DIR =  Join-Path $Env:TEMP $CONFIG.Id
    }

    $SECRETS_FILE = Join-Path $INSTALL_DIR 'secrets.yml'
    $S3_URI =       "https://s3.amazonaws.com/$($Env:CHOCO_BUCKET)/packages/$($CONFIG.Id).zip"
    If ($mode.ToLower() -eq "t"){$INSTALLED = ""}
    Else {$INSTALLED =    $Env:CHOCO_INSTALLED_PACKAGES.Split(';')}


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
            
            # Check if the package is already downloaded and extracted
            If (!(gci $INSTALL_DIR -Recurse -Include *.exe, *.msi -ErrorAction SilentlyContinue)){
            
                # Download and extract ZIP from S3
                Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
                Install-ChocolateyZipPackage `
                    -PackageName "$($CONFIG.Id)" `
                    -UnzipLocation "$INSTALL_DIR" `
                    -Url "$S3_URI"
            }

            # Put any secrets into the environment
            if (Test-Path $SECRETS_FILE) {
            
                # Convert secrets.yml
                [array]$secrets = Get-Content -Raw $SECRETS_FILE | ConvertFrom-Yaml
                $total = $secrets.Keys.Count
                $count = 0

                # Add environment variables
                If ($total -gt 1){
                
                    Do { [System.Environment]::SetEnvironmentVariable($secrets.Keys[$count], $secrets.Values[$count], 'Process');$count ++ } Until ($count -eq $total)
            
                }
                Else { [System.Environment]::SetEnvironmentVariable($secrets.Keys, $secrets.Values, 'Process') }

            }


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

        If (!(gci $INSTALL_DIR -Recurse -Include *.exe, *.msi -ErrorAction SilentlyContinue)){

            # Download and extract ZIP from S3
            Write-Output "Unzipping $($CONFIG.Id) From $S3_URI"
            Install-ChocolateyZipPackage `
                -PackageName "$($CONFIG.Id)" `
                -UnzipLocation "$INSTALL_DIR" `
                -Url "$S3_URI"
                
        } 

        # Put any secrets into the environment
        if (Test-Path $SECRETS_FILE -ErrorAction SilentlyContinue) {
           
            # Convert secrets.yml
            [array]$secrets = Get-Content -Raw $SECRETS_FILE | ConvertFrom-Yaml
            $total = $secrets.Keys.Count
            $count = 0

            # Add environment variables
            If ($total -gt 1){

                Do { [System.Environment]::SetEnvironmentVariable($secrets.Keys[$count], $secrets.Values[$count], 'Process');$count ++ } Until ($count -eq $total)
 
            }
            Else { [System.Environment]::SetEnvironmentVariable($secrets.Keys, $secrets.Values, 'Process') }
        
        }

    }

    ##############################################
    ############## Registry Files ################
    ##############################################
    Function Registry {
    
        # Set all the Registry Keys listed in config
        $hives = ($CONFIG.Registry | Get-Member -MemberType NoteProperty).Name
        
        foreach ($hive in $hives) {
            
            $regKeys = ($CONFIG.Registry.$hive | Get-Member -MemberType NoteProperty).Name

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
                        -Value $regValue `
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
}

##################################
###### Troubleshooting Mode ######
##################################

Function Troubleshoot($CHOCO_BUCLET, $APP) {

    write-host "TROUBLESHOOTING MODE!!" -ForegroundColor Green

    If (!($CHOCO_BUCKET)){
    
        Write-Host "ERROR: Missing S3 Bucket!" -ForegroundColor Red
        
        Do {
            
            $CHOCO_BUCKET = Read-Host "Enter S3 Bucket Name"
            Write-Host "You entered '$CHOCO_BUCKET'" -ForegroundColor Yellow `n
            $bucketans = Read-Host "Is this correct? (y or n)"

        }Until ($CHOCO_BUCKET -and ($bucketans.ToLower() -eq 'y' -or $bucketans.ToLower() -eq 'yes'))
    
    }

    $env:CHOCO_BUCKET = $CHOCO_BUCKET

    Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

    [Environment]::SetEnvironmentVariable('ChocolateyIgnoreChecksums', $true, 'Process')
    
    If (!($APP)){
        
        Write-Host "No app specified, defaulting to $PSScriptRoot" -ForegroundColor Yellow
        $appans = Read-Host "Do you want to specify a different app to troubleshoot? (y/n)"
    
        If ($appans.ToLower() -eq "y" -or $appans.ToLower() -eq "yes"){$APP = Read-Host "Enter app name to troubleshoot"}
    }
    
    If ($APP){
    
        Do {
            $paths = "$env:ALLUSERSPROFILE\chocolatey\lib", "$env:ALLUSERSPROFILE\chocolatey\lib-bad"
            $paths | % {If (Test-Path "$_\*$APP*"){$TOOLS_DIR = (gci "$_\*$APP*\tools" -Directory).FullName}}
            
            Write-Host "$APP $TOOLS_DIR"

            If (!($TOOLS_DIR)){
                Write-Host "$APP not found, please choose from list" -ForegroundColor Red
                $paths | % {(gci $_ -Directory).Name}
            
                Do {
            
                    $APP = Read-Host "Enter application to troubleshoot"
                    Write-Host "You entered '$APP'" -ForegroundColor Yellow `n
                    $appans = Read-Host "Is this correct? (y or n)"

                }Until ($APP -and ($appans.ToLower() -eq 'y' -or $appans.ToLower() -eq 'yes'))
            }
        }
        Until($TOOLS_DIR)
        
        Try {$CONFIG = Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.json') -ErrorAction Stop | ConvertFrom-Json}
        Catch {write-host "config.json missing from $TOOLS_DIR"}
        
        If (Test-Path $(Join-Path "$env:windir\Temp\chocolatey" $CONFIG.ID)){$INSTALL_DIR = $(Join-Path "$env:windir\Temp\chocolatey" $CONFIG.ID)}
        Else {$INSTALL_DIR =  Join-Path $Env:TEMP $CONFIG.Id}

    }
    Write-Host $INSTALL_DIR
    Write-Host $CONFIG
    Main $TOOLS_DIR $INSTALL_DIR $CONFIG
}

########################################
########### Uninstall Mode #############
########################################

Function Uninstall($APP) {

    write-host "UNINSTALL MODE!!" -ForegroundColor Green

    $apps = & choco.exe list --local-only

    If (!($app)){
    
        Write-Host "Currently installed apps..." -ForegroundColor Yellow
        & choco.exe list --local-only
       
        Do {

            $app = Read-Host "What app would you like to uninstall?"
            Write-Host "You entered '$app', you are about to uninstall the following choco packages:" -ForegroundColor Yellow `n
            $apps -match $app
            $appans = Read-Host "Is this correct? (y or n)"

        }Until ($app -and ($appans.ToLower() -eq 'y' -or $appans.ToLower() -eq 'yes'))

        $apps -match $app | % { Try { & choco.exe uninstall $_.Split()[0] -f -a -y} Catch { "Error uninstalling $_" }}
        
            
    }
    Else { $apps -match $app | % { Try { & choco.exe uninstall $_.Split()[0] -f -a -y } Catch { "Error uninstalling $_" }}}

    exit
}

If ($mode.ToLower() -eq "t"){Troubleshoot $CHOCO_BUCKET $APP}
ElseIf ($mode.ToLower() -eq "u"){Uninstall $APP}
Else {Main}