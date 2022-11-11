<#
.SYNOPSIS

    AppStream 2.0 installer script
.DESCRIPTION

    Perform standard or custom Windows tasks on an AppStream 2.0 Image Builder for Fleet automation. Install applications and choco packages, copy files, create environment variables, edit registry, services and scheduled tasks.
.PARAMETER Mode

    The operating mode of this script. There are 2 modes for troubleshooting applications locally during preliminary test. 
    t or troubleshoot = TROUBLESHOOTING MODE - Enables local instance troubleshooting for applications
    u or uninstall = UNINSTALL MODE - Runs choco uninstall
    update = UPDATE MODE - Installs Windows Updates
.PARAMETER App

    Application name for TROUBLESHOOTING or UNINSTALL modes.
.PARAMETER S3

    S3 bucket name for installer files. Bucket name only, do not include entire path. i.e. if S3 bucket path is https://s3.amazonaws.com/mybucket input 'mybucket'
.EXAMPLE

    PS C:\Programdata\chocolatey\lib-bad\firefox> 
    .\chocolateyinstall.ps1 -Mode t
.EXAMPLE

    PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates>
    .\chocolateyinstall.ps1 -Mode t -App firefox -S3 mybucket
.EXAMPLE

    PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates> 
    .\chocolateyinstall.ps1 -Mode u -App chrome
.EXAMPLE

    PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates> 
    .\chocolateyinstall.ps1 -Mode update
.LINK

    https://github.com/CU-CommunityApps/choco-packages
    https://confluence.cornell.edu/display/CLOUD/Cornell+Stream
.NOTES

    TROUBLESHOOTING and UNINSTALL modes can be used locally when performing preliminary application testing
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false,Position=1,HelpMessage="Installation Mode - 't' (troubleshoot), 'u' (uninstall) or 'update' (install windows updates)")]
    [ValidateNotNullOrEmpty()]
    [string]$Mode,
    [Parameter(Mandatory=$false,Position=2,HelpMessage="Application")]
    [ValidateNotNullOrEmpty()]
    [string]$App,
    [Parameter(Mandatory=$false,Position=3,HelpMessage="S3 Bucket Name")]
    [ValidateNotNullOrEmpty()]
    [string]$S3

)

Function Main($TOOLS_DIR, $INSTALL_DIR, $CONFIG) {

    If (!($Mode)){$ErrorActionPreference = 'Stop'}
    
    if ((-Not (Get-Module -ListAvailable -Name 'powershell-yaml')) -Or (-Not (Get-Module -ListAvailable -Name 'PSSQLite'))) {
        Install-PackageProvider -Name 'NuGet' -Force
        Install-Module 'powershell-yaml' -Force
        Install-Module 'PSSQLite' -Force
    }
    
    Import-Module "powershell-yaml"
    Import-Module "PSSQLite"

    $CHOCO =        [io.path]::combine($Env:ALLUSERSPROFILE, 'chocolatey', 'bin', 'choco.exe')
    $REG =          [io.path]::combine($Env:SYSTEMROOT, 'System32', 'reg.exe')
    $USER_DIR =     Join-Path $Env:SYSTEMDRIVE 'Users'
    $DEFAULT_HIVE = [io.path]::combine($USER_DIR, 'Default', 'NTUSER.DAT')
    $STARTUP =      [io.path]::combine($Env:ALLUSERSPROFILE, 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'StartUp', '*')
    $APP_CATALOG =  [io.path]::combine($Env:ALLUSERSPROFILE, 'Amazon', 'Photon', 'PhotonAppCatalog.sqlite')
    $APP_ICONS =    [io.path]::combine($Env:ALLUSERSPROFILE, 'Amazon', 'Photon', 'AppCatalogHelper', 'AppIcons')

    If (!($TOOLS_DIR)){
        $TOOLS_DIR = $PSScriptRoot
        $CONFIG =   Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.yml') | ConvertFrom-Yaml | ConvertTo-Yaml -JsonCompatible | ConvertFrom-Json
        $INSTALL_DIR =  Join-Path $TOOLS_DIR 'installer'
    }

    $SECRETS_FILE = Join-Path $INSTALL_DIR 'secrets.yml'

    # Make useful directories available to the environment
    [Environment]::SetEnvironmentVariable('INSTALL_DIR', $INSTALL_DIR, 'Process')
    [Environment]::SetEnvironmentVariable('TOOLS_DIR', $TOOLS_DIR, 'Process')

        
    If (Test-Path $SECRETS_FILE) {
        
        # Convert secrets.yml
        [array]$secrets = Get-Content -Raw $SECRETS_FILE | ConvertFrom-Yaml 
        $total = $secrets.Keys.Count
        $count = 0

        # Add environment variables
        If ($total -gt 1){
            
            Do { [System.Environment]::SetEnvironmentVariable($secrets.Keys[$count], $secrets.Values[$count], 'Process');$count ++ } Until ($count -eq $total)
        
        }
    
        # Put any secrets into the environment
        If (Test-Path $SECRETS_FILE) {
            
            # Convert secrets.yml
            [array]$secrets = Get-Content -Raw $SECRETS_FILE | ConvertFrom-Yaml
            $total = $secrets.Keys.Count
            $count = 0

            # Add environment variables
            If ($total -gt 1){
                
                $secrets.Keys | % {
                    
                    # Get array position of static env_var
                    $arrayPos = $secrets.Keys.IndexOf($_)

                    If ($_ -match "STATIC_SYSTEM"){

                        # Add machine level env_var
                        [System.Environment]::SetEnvironmentVariable($secrets.Keys[$arrayPos], $secrets.Values[$arrayPos], 'Machine')

                    }
                    # Add process level env_var
                    Else {[System.Environment]::SetEnvironmentVariable($secrets.Keys[$arrayPos], $secrets.Values[$arrayPos], 'Process')}
            
                }

            }
            ElseIf ($secrets.Keys -match "STATIC_SYSTEM") { [System.Environment]::SetEnvironmentVariable($secrets.Keys, $secrets.Values, 'Machine') }
            Else { [System.Environment]::SetEnvironmentVariable($secrets.Keys, $secrets.Values, 'Process') }

        }
    }

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
            [Environment]::SetEnvironmentVariable($envVar, $envValue, 'Machine')
        }
    }

    ##############################################
    ################ Choco Packs #################
    ##############################################
    Function Choco {

        # Install any listed Choco Gallery packages
        $CONFIG.ChocoPackages | % {
            Write-Output "Installing Choco Package $($_.PackageName)"

            Start-Process `
                -FilePath "$CHOCO" `
                -ArgumentList "install $($_.PackageName) --no-progress -r -y --install-arguments='$($_.InstallParams)'" `
                -NoNewWindow -Wait
        }
    }

    ##############################################
    ################ Installers ##################
    ##############################################
    Function Installers {

        # Install each installer file
        $CONFIG.Install | % {

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

    ##############################################
    ############## Registry Files ################
    ##############################################
    Function Registry {
    
        # Set all the Registry Keys listed in config
        $hives = ($CONFIG.Registry | Get-Member -MemberType NoteProperty).Name
        
        foreach ($hive in $hives) {
            
            $regKeys = ($CONFIG.Registry.$hive | Get-Member -MemberType NoteProperty).Name

            # Load Default User
            if ($hive -eq 'HKUD' -and !($Mode)) {
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
                If (!(Test-Path "$regKeyPath")){New-Item -Path "$regKeyPath" -Force} 

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

            if ($hive -eq 'HKUD' -and !($Mode)) {
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

            If (!(Test-Path $destPath)){
                New-Item `
                    -Path $(Split-Path -Path "$destPath") `
                    -ItemType "Directory" `
                    -Force
            }

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

    ##############################################
    ############## Session Scripts ###############
    ##############################################
    Function SessionScripts {
        
        $STARTUP_USER = "$env:ALLUSERSPROFILE\SessionScripts\startupuser.ps1"
        $STARTUP_SYSTEM = "$env:ALLUSERSPROFILE\SessionScripts\startupsystem.ps1"
        $SHUTDOWN_USER = "$env:ALLUSERSPROFILE\SessionScripts\shutdownuser.ps1"
        $SHUTDOWN_SYSTEM = "$env:ALLUSERSPROFILE\SessionScripts\shutdownsystem.ps1"
        
        If ($CONFIG.Scripts.start.System){Get-Content $([Environment]::ExpandEnvironmentVariables($CONFIG.Scripts.start.System)) | Add-Content $STARTUP_SYSTEM}
        If ($CONFIG.Scripts.start.User){Get-Content $([Environment]::ExpandEnvironmentVariables($CONFIG.Scripts.start.User)) | Add-Content $STARTUP_USER}
        If ($CONFIG.Scripts.end.System){Get-Content $([Environment]::ExpandEnvironmentVariables($CONFIG.Scripts.end.System)) | Add-Content $SHUTDOWN_SYSTEM}
        If ($CONFIG.Scripts.end.User){Get-Content $([Environment]::ExpandEnvironmentVariables($CONFIG.Scripts.end.User)) | Add-Content $SHUTDOWN_USER}   
    
    }
    
    ##############################################
    ################# AppCatalog #################
    ##############################################
    Function AppCatalog {
        if (-Not (Test-Path $APP_ICONS)) {
            New-Item -ItemType Directory -Force -Path $APP_ICONS
        }
        
        if (-Not (Test-Path $APP_CATALOG)) {
            $create_table = 'CREATE TABLE IF NOT EXISTS "Applications" ("Name" TEXT NOT NULL CONSTRAINT "PK_Applications" PRIMARY KEY, "AbsolutePath" TEXT, "DisplayName" TEXT, "IconFilePath" TEXT, "LaunchParameters" TEXT, "WorkingDirectory" TEXT)'
            Invoke-SqliteQuery -DataSource $APP_CATALOG -Query $create_table
            
            $acl = Get-Acl $APP_CATALOG
            $permission = "Everyone","FullControl","Allow"
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
            $acl.SetAccessRule($rule)
            $acl | Set-Acl $APP_CATALOG
        }
        
        $app_entry = "INSERT INTO Applications (Name, AbsolutePath, DisplayName, IconFilePath, LaunchParameters, WorkingDirectory) VALUES (@name, @path, @display, @icon, @params, @workdir)"
        $applications = ($CONFIG.Applications | Get-Member -MemberType NoteProperty).Name
        
        foreach ($application in $applications) {
            Write-Output "Creating App Catalog Entry for $($CONFIG.Applications.$application.DisplayName)"
            
            $app_icon_src = [io.path]::combine($TOOLS_DIR, 'icons', "$application.png")
            $app_icon = Join-Path "$APP_ICONS" "$application.png"
            Copy-Item -Path $app_icon_src -Destination $app_icon
            
            $path = [Environment]::ExpandEnvironmentVariables($CONFIG.Applications.$application.Path).Replace('%%', '%')
            $display = $CONFIG.Applications.$application.DisplayName
            $params = [Environment]::ExpandEnvironmentVariables($CONFIG.Applications.$application.LaunchParams).Replace('%%', '%')
            $workdir = [Environment]::ExpandEnvironmentVariables($CONFIG.Applications.$application.WorkDir).Replace('%%', '%')
            
            Invoke-SqliteQuery -DataSource $APP_CATALOG -Query $app_entry -SqlParameters @{
                name = "$application"
                path = "$path"
                display = "$display"
                icon = "$app_icon"
                params = "$params"
                workdir = "$workdir"
            }
        }
    }
    
    Function PostInstall {
    
        # Run Postinstall PowerShell script
        Write-Output "Running postinstall.ps1..."
        Invoke-Expression $(Join-Path "$TOOLS_DIR" 'postinstall.ps1')
        
    }
    
    # Only run config.yml sections if specified
    If ($CONFIG.Environment){EnvVars}
    If ($CONFIG.ChocoPackages){Choco}
    If ($CONFIG.Install){Installers}
    If ($CONFIG.Registry){Registry}
    If ($CONFIG.Files){Files}
    If ($CONFIG.Services){Services}
    If ($CONFIG.ScheduledTasks){SchedTask}
    
    # Only run if package install is on an AppStream resource
    If ($env:AoD_Manual){
        write-output "AppStream Resource"
        If ($CONFIG.Scripts){SessionScripts}
        If ($CONFIG.Applications){AppCatalog}
        
        PostInstall        

        # Remove any files that might have been added to the Startup directory
        Write-Output "Removing any startup files"
        Remove-Item -Recurse -Force "$STARTUP"
    }
    Else {
        write-output "Not AppStream resource"
        PostInstall
    }   

    # Remove all installation files from disk
    if ((Test-Path $INSTALL_DIR) -and ($Mode.ToLower() -ne 't')) {
        Write-Output "Removing Installer Files..."
        Remove-Item -Recurse -Force "$INSTALL_DIR"
    }

    # Update environment to list this package as installed
    $INSTALLED += $CONFIG.Id
    $INSTALLED = $INSTALLED -Join ';'

    Write-Output "$($CONFIG.Id) Install Complete!"
}

############################################
########### Troubleshooting Mode ###########
############################################
Function Troubleshoot($CHOCO_BUCKET, $App) {

    write-host "TROUBLESHOOTING MODE!!" -ForegroundColor Green

    # If no S3 bucket was specified, get one
    If (!($S3)){
    
        Write-Host "ERROR: Missing S3 Bucket!" -ForegroundColor Red
        
        Do {
            
            $S3 = Read-Host "Enter S3 Bucket Name"
            Write-Host "You entered '$S3'" -ForegroundColor Yellow `n
            $bucketans = Read-Host "Is this correct? (y/n)"

        }Until ($S3 -and ($bucketans.ToLower() -eq 'y' -or $bucketans.ToLower() -eq 'yes'))
    
    }

    $env:CHOCO_BUCKET = $S3

    # Import chocolatey powershell module
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

    # Ignore checksums during troubleshooting only
    [Environment]::SetEnvironmentVariable('ChocolateyIgnoreChecksums', $true, 'Process')
    
    # If no application specified, get one
    If (!($APP)){
        
        Do {
            Write-Host "No app specified, defaulting to $PSScriptRoot" -ForegroundColor Yellow
            $appans = Read-Host "Do you want to specify a different app to troubleshoot? (y/n)"
        }Until($appans.ToLower() -eq 'y' -or $appans.ToLower() -eq 'yes' -or $appans.ToLower() -eq 'n' -or $appans.ToLower() -eq 'no')
    
        If ($appans.ToLower() -eq "y" -or $appans.ToLower() -eq "yes"){$App = Read-Host "Enter app name to troubleshoot"}
    }
    
    If ($App){
    
        Do {
            # Search chocolatey directories for specified app
            #$paths = "$env:ALLUSERSPROFILE\chocolatey\lib", "$env:ALLUSERSPROFILE\chocolatey\lib-bad"
            $paths = "$env:USERPROFILE\Desktop"
            $paths | % {If (Test-Path "$_\*$App.*"){$TOOLS_DIR = (gci "$_\*$App.*\tools" -Directory).FullName}}
            
            # Choose app from the list
            If (!($TOOLS_DIR)){
                Write-Host "$App not found, please choose from list" -ForegroundColor Red
                $paths | % {(gci $_ -Directory).Name}
            
                Do {
            
                    $APP = Read-Host "Enter application to troubleshoot"
                    Write-Host "You entered '$APP'" -ForegroundColor Yellow `n
                    $appans = Read-Host "Is this correct? (y or n)"

                }Until ($APP -and ($appans.ToLower() -eq 'y' -or $appans.ToLower() -eq 'yes'))
            }
        }
        Until($TOOLS_DIR)
        
        Try {$CONFIG = Get-Content -Raw -Path $(Join-Path $TOOLS_DIR 'config.yml') -ErrorAction Stop | ConvertFrom-Yaml}
        Catch {write-host "config.yml missing from $TOOLS_DIR"}
        
        # Check if the app has already been downloaded and extracted
        If (Test-Path $(Join-Path "$env:USERPROFILE\Desktop" "$($CONFIG.ID).$($CONFIG.Version)")){$INSTALL_DIR = $(Join-Path "$env:USERPROFILE\Desktop" "$($CONFIG.ID).$($CONFIG.Version)\tools\installer")}
        ElseIf (Test-Path $(Join-Path "$env:windir\Temp\chocolatey" $CONFIG.ID)){$INSTALL_DIR = $(Join-Path "$env:windir\Temp\chocolatey" $CONFIG.ID)}
        Else {$INSTALL_DIR =  Join-Path $Env:TEMP $CONFIG.Id}

    }

    # Call Main with params
    Main $TOOLS_DIR $INSTALL_DIR $CONFIG
}

################################################
################ Uninstall Mode ################
################################################
Function Uninstall($App) {

    write-host "UNINSTALL MODE!!" -ForegroundColor Green

    # List locally installed choco packages
    $apps = & choco.exe list --local-only

    # App parameter missing, get app
    If (!($App)){
    
        Write-Host "Currently installed apps..." -ForegroundColor Yellow
        & choco.exe list --local-only
       
        Do {

            $app = Read-Host "What app would you like to uninstall?"
            Write-Host "You entered '$app', you are about to uninstall the following choco packages:" -ForegroundColor Yellow `n
            $apps -match $app
            $appans = Read-Host "Is this correct? (y or n)"

        }Until ($app -and ($appans.ToLower() -eq 'y' -or $appans.ToLower() -eq 'yes'))

        # Uninstall choco package
        $apps -match $app | % { Try { & choco.exe uninstall $_.Split()[0] -f -a -y} Catch { "Error uninstalling $_" }}
        
            
    }
    # Uninstall choco package
    Else { $apps -match $app | % { Try { & choco.exe uninstall $_.Split()[0] -f -a -y } Catch { "Error uninstalling $_" }}}
    
    Exit
}

################################################
################# Update Mode ##################
################################################
Function Update {
    
    Write-Output "Restarting computer before installing updates"
    Restart-Computer
    write-output "Installing Windows Updates"
    
    # Install PSWindowsUpdate Module
    Try {If (!(Get-Module -ListAvailable -Name 'PSWindowsUpdate')){Install-Module 'PSWindowsUpdate' -Force -Verbose}}
    Catch {Write-Output "Could not install PSWindowsUpdate module"}

    # Install missing security and critical Windows Updates
    Try {Get-WUInstall -WindowsUpdate -Install -Category 'Security Updates', 'Critical Updates' -IgnoreReboot -AcceptAll -Verbose}
    Catch {Write-Output "Updates failed"}

    Exit

}

################################################
################ Optimize Mode #################
################################################
Function Optimize {

    $procLoc = "$env:SystemDrive\Procmon"
    $proc = "$env:SystemDrive\Procmon\procmon.exe"
    $prewarm = "$env:ProgramData\Amazon\Photon\Prewarm"
    $prewarmUsers = "$env:SystemDrive\Users\ImageBuilderAdmin\Temp", "$env:SystemDrive\Users\Default\Temp"
    $packageLoc = "$env:windir\Temp\choco-bootstrap\choco-packages\packages"

    # Check if procmon.exe exists
    If (!(Test-Path $proc)){Write-Output "Process Explorer missing";exit}

    # Check if any applications failed to install
    If (Test-Path "$env:ALLUSERSPROFILE\chocolatey\lib-bad"){Write-Output "Applications failed to install";exit}
    
    write-output "Optimizing Applications"
    
    # Search chocolatey directories for each app
    $apps = gci "$env:ALLUSERSPROFILE\chocolatey\lib" -Filter "config.json" -Recurse
    
    # Run process explorer to capture prewarm file requirements
    Start-Process $proc -ArgumentList "/accepteula /loadconfig $procLoc\ProcmonConfiguration.pmc /profiling /quiet /minimized /backingfile $procLoc\back.pml";Start-Sleep -Seconds 10

    $apps | % {
    
        $CONFIG = Get-Content -Raw -Path $_.FullName -ErrorAction Stop | ConvertFrom-Json
        
        Write-Output "Optimizing $($CONFIG.Id)"
        
        $launchApps = (Select-String -Path "$packageLoc\$($CONFIG.Id)\config.yml" -Pattern "Path:").Line
        $launchApps | % { 
            
            # Edit strings
            $path = $_ -replace "Path:"
            
            # Expand environment variables
            $path = [Environment]::ExpandEnvironmentVariables($path).Replace('%%', '%')
            
            # Edit strings
            $path = $path -replace "'"
           
            # Launch each application listed in config.yml
            Try {Start-Process "$path"; If ($? -eq $true){Write-Output "Successfully optimized $path"; Start-Sleep -Seconds 60}}
            Catch {Write-Output "Failed to optimize $($CONFIG.Id) $path"}

        }

    }

    # Stop process explorer capture process
    Start-Process $proc -ArgumentList "/terminate";Start-Sleep -Seconds 10

    # Convert log to .csv
    Start-Process $proc -ArgumentList "/openlog $procLoc\back.pml /saveas $procLoc\back.csv";Start-Sleep -Seconds 10

    # Only grab .exe and .dll files critical for app operation
    $csv = import-csv "$procLoc\back.csv" | where {$_.Path -like "*.exe" -or $_.Path -like "*.dll"} | sort Path -Unique

    # Remove headers 
    $csv | ConvertTo-Csv | select -Skip 2 | Out-File "$procLoc\PrewarmManifest.csv"

    # Remove quotes and move file to default location for sysprep
    gc "$procLoc\PrewarmManifest.csv" | % {$_ -replace '"'} > "$prewarm\PrewarmManifest.txt"

    # Copy PrewarmManifest.txt to additional file locations
    $prewarmUsers | % {If (!(Test-Path $_ -PathType Container)){New-Item -ItemType Directory -Path $_ -Force};cp "$prewarm\PrewarmManifest.txt" "$_" -Force}

    Exit

}

# Run Troubleshooting Mode if -Mode t or T is specified during runtime
If ($Mode.ToLower() -eq "t" -or $Mode.ToLower() -eq "troubleshoot"){Troubleshoot $S3 $App}

# Run Uninstall Mode if -Mode u or U is specified during runtime
ElseIf ($Mode.ToLower() -eq "u" -or $Mode.ToLower() -eq "uninstall"){Uninstall $App}

# Run Windows Updates
ElseIf ($Mode.ToLower() -eq "update"){Update}

# Run App Optimization
ElseIf ($Mode.ToLower() -eq "optimize"){Optimize}

# Run Main if no Mode specified
Else {Main}
