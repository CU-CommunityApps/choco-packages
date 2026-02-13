[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Assume machine role
Set-AWSCredential -ProfileName appstream_machine_role

$BUILD_DIR = Join-Path $Env:TEMP "image-build"
$PACKAGE_DIR = Join-Path $BUILD_DIR "packages"
$CHOCO_REPO = "https://chocolatey.org/api/v2"
$BUILDER_PACKAGE = "image-builder-cornell"
$BUILDER_VERSION = "1.0"
$STARTUP_USER = "$env:ALLUSERSPROFILE\SessionScripts\startupuser.ps1"
$STARTUP_SYSTEM = "$env:ALLUSERSPROFILE\SessionScripts\startupsystem.ps1"
$SHUTDOWN_USER = "$env:ALLUSERSPROFILE\SessionScripts\shutdownuser.ps1"
$SHUTDOWN_SYSTEM = "$env:ALLUSERSPROFILE\SessionScripts\shutdownsystem.ps1"
$POWERSHELL_PATH = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$SESSION_SCRIPTS = "$env:SystemDrive\AppStream\SessionScripts\config.json"
$BUILDER_STDOUT_LOG = "$env:SystemDrive\builder-console.log"
$BUILDER_STDERR_LOG = "$env:SystemDrive\builder-console-err.log"
$SESSION_CONTENTS = Get-Content $SESSION_SCRIPTS | Out-String | ConvertFrom-Json
$LONGPATH_KEY = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
$REBOOT_LOCK = "$env:ALLUSERSPROFILE\TEMP\REBOOT.lock"
$DRIVER_LOCK = "$env:ALLUSERSPROFILE\TEMP\DRIVER.lock"
$OSVERSION = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

Function G4dn{
    Write-Output "G4 instance, downloading latest GRID driver"
    $choco_home="$env:ALLUSERSPROFILE\chocolatey"

    $Bucket = "ec2-windows-nvidia-drivers"
    $KeyPrefix = "latest"
    $LocalPath = "$choco_home\lib\NVIDIA"
    $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
    foreach ($Object in $Objects) {
        $LocalFileName = $Object.Key
        if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
            $LocalFilePath = Join-Path $LocalPath $LocalFileName
            Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
        }
    }

    Write-Output "Installing GRID driver"
    $file = gci "$choco_home\lib\NVIDIA\latest" -Filter "*.exe"
    start-process "$choco_home\tools\7z.exe" -ArgumentList "x $($file.FullName) -o$($file.Directory)" -Wait
    start-process "$choco_home\lib\NVIDIA\latest\setup.exe" -ArgumentList "-s -n" -Wait
    
    # Remove Windows App - The pop up still occurs because of the nvidia control panel service which needs to run apparently...
    # $package = Get-AppxProvisionedPackage -online | Where-Object {$_.displayName -match "NVIDIACorp.NVIDIAControlPanel"}
    # remove-AppxProvisionedPackage -online -packagename $package.PackageName
   
    # This happens in streaming instance...
    # https://www.vjonathan.com/post/dem-non-persistent-vdi-deployment-and-nvidia-control-panel-missing/
    
    # Add login script for each user (session script) to register the missing Nvidia Control Panel UWP (Universal Windows Platform) app
    # DCH version only, but AWS doesn't seem to have the standard driver version available at this time.
    $nvidiaPackage = Get-AppxPackage -Name *nvidia*
    "Add-AppxPackage -Register '$($nvidiaPackage.InstallLocation)\AppxManifest.xml' -DisableDevelopmentMode" | Add-Content "$env:ALLUSERSPROFILE\SessionScripts\startupuser.ps1"
    
    New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing
    New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value "1"
}

Function Symlinks{
    # Run as elevated administrator
    $cfg    = "$env:TEMP\secpol.inf"
    $backup = "$env:TEMP\secpol_backup_$(Get-Date -Format yyyyMMdd_HHmmss).inf"
    $right      = 'SeCreateSymbolicLinkPrivilege'
    $adminSid   = '*S-1-5-32-544'  # BUILTIN\Administrators
    $systemSid  = '*S-1-5-18'      # NT AUTHORITY\SYSTEM
    # 1. Export local security policy
    secedit /export /cfg $cfg | Out-Null
    # 2. Backup
    Copy-Item $cfg $backup -Force
    # 3. Read file
    $content = Get-Content $cfg
    # Helper: find line index
    function Get-LineIndex {
        param($lines, $pattern)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match $pattern) { return $i }
        }
        return $null
    }
    $lineIndex = Get-LineIndex -lines $content -pattern "^$right"
    if ($lineIndex -ne $null) {
        # Existing line
        $line   = $content[$lineIndex]
        $parts  = $line -split '=', 2
        $values = @()
        if ($parts.Count -gt 1 -and $parts[1].Trim()) {
            $values = $parts[1].Split(',') |
                      ForEach-Object { $_.Trim() } |
                      Where-Object { $_ -ne '' }
        }
        if ($values -notcontains $adminSid)  { $values += $adminSid }
        if ($values -notcontains $systemSid) { $values += $systemSid }
        $content[$lineIndex] = "$right = " + ($values -join ',')
    }
    else {
        # No line yet – add under [Privilege Rights]
        $privIndex = Get-LineIndex -lines $content -pattern '^\[Privilege Rights\]'
        if ($privIndex -eq $null) { throw "Could not find [Privilege Rights] section in $cfg" }
        $newLine = "$right = $adminSid,$systemSid"
        $before  = $content[0..$privIndex]
        $after   = $content[($privIndex + 1)..($content.Count - 1)]
        $content = $before + $newLine + $after
    }
    # 4. Write back
    Set-Content -Path $cfg -Value $content -Encoding Unicode
    Write-Host "Updated $right in $cfg"
    Write-Host "Backup saved as $backup"
    # 5. Apply
    secedit /configure /db secedit.sdb /cfg $cfg /areas USER_RIGHTS | Out-Null
    Write-Host "Policy updated. Logoff/reboot may be required."
}

if (-Not (Test-Path $BUILD_DIR)) {

    # Wait Five Minutes on First Run
    Start-Sleep -Seconds 300

    # Set system time zone
    Set-TimeZone -Name "Eastern Standard Time"
    
    # Create Session Script Template Files
    If (!(Test-Path "$env:ALLUSERSPROFILE\SessionScripts")){New-Item -Path $env:ALLUSERSPROFILE -ItemType Directory -Name SessionScripts}
    If (!(Test-Path $STARTUP_USER)){New-Item -Path "$env:ALLUSERSPROFILE\SessionScripts" -Name startupuser.ps1}
    If (!(Test-Path $STARTUP_SYSTEM)){New-Item -Path "$env:ALLUSERSPROFILE\SessionScripts" -Name startupsystem.ps1}
    If (!(Test-Path $SHUTDOWN_USER)){New-Item -Path "$env:ALLUSERSPROFILE\SessionScripts" -Name shutdownuser.ps1}
    If (!(Test-Path $SHUTDOWN_SYSTEM)){New-Item -Path "$env:ALLUSERSPROFILE\SessionScripts" -Name shutdownsystem.ps1}

    # Point scripts to AppStream session script location / format

    # Startup System
    $SESSION_CONTENTS.SessionStart.executables[0].filename = $POWERSHELL_PATH
    $SESSION_CONTENTS.SessionStart.executables[0].arguments = "-File `"$STARTUP_SYSTEM`""

    # Startup User
    $SESSION_CONTENTS.SessionStart.executables[1].filename = $POWERSHELL_PATH
    $SESSION_CONTENTS.SessionStart.executables[1].arguments = "-File `"$STARTUP_USER`""

    # Shutdown System
    $SESSION_CONTENTS.SessionTermination.executables[0].filename = $POWERSHELL_PATH
    $SESSION_CONTENTS.SessionTermination.executables[0].arguments = "-File `"$SHUTDOWN_SYSTEM`""

    # Shutdown User
    $SESSION_CONTENTS.SessionTermination.executables[1].filename = $POWERSHELL_PATH
    $SESSION_CONTENTS.SessionTermination.executables[1].arguments = "-File `"$SHUTDOWN_USER`""

    # Add contents to AppStream config.json file
    $SESSION_CONTENTS | ConvertTo-Json -Depth 3 | Set-Content $SESSION_SCRIPTS

    # Add Long File Path Support for Server '16/'19
    Set-ItemProperty -Path $LONGPATH_KEY -Name "LongPathsEnabled" -Value 1
    
    # Create Temp Directories
    Write-Output "Creating Temporary Build Directories"
    New-Item -ItemType Directory -Force -Path $BUILD_DIR
    New-Item -ItemType Directory -Force -Path $PACKAGE_DIR
    
    # No Path set for SYSTEM so move to BUILD_DIR
    Set-Location $BUILD_DIR
    
    # Install Chocolatey
    Write-Output "Installing Chocolatey"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Install Sysinterals
    Write-Output "Installing Sysinterals"
    Start-Process -FilePath "choco.exe" -ArgumentList "install sysinternals --no-progress -r -y --ignore-checksums" -NoNewWindow -Wait

    # Parse EC2 Metadata
    $user_data_uri = "http://169.254.169.254/latest/user-data"
    $bucket_prefix = "image-build"
    $user_data = (irm -Uri $user_data_uri).resourceARN
    $region = $user_data.Split(":")[3]
    $account = $user_data.Split(":")[4]
    $build_id = $user_data.Split(":")[5].Split("/")[1]
    $package_branch = $build_id.Split(".")[1]
    $image_id = $build_id.Split(".")[2..$build_id.Split(".").Length] -join "."
    $build_bucket = "$bucket_prefix-$account-$region"
    $build_package_uri = "https://s3.amazonaws.com/$build_bucket/packages/$package_branch/$BUILDER_PACKAGE.$BUILDER_VERSION.nupkg"
    $application = $build_id.Split(".")[0]
    
    # Parse Database
    $statement = "SELECT entry_info FROM `"$application`" WHERE entry_type='ImageBuild' AND entry_id='$image_id'"
    $resp = Invoke-DDBDDBExecuteStatement -Statement $statement
    $build_info = $resp.entry_info.M

    # Set system level environment variable for manual processing
    If ($build_info.Manual.BOOL -eq $true){[System.Environment]::SetEnvironmentVariable("AoD_Manual", $true, 'Machine')}
    Else {[System.Environment]::SetEnvironmentVariable("AoD_Manual", $false, 'Machine')}
    
    # Remove Internet Explorer
    Write-Output "Uninstalling IE 11"
    Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart
    
    # Install .NET 4.8
    Write-Output "Installing .NET 4.8"
    Start-Process -FilePath "choco.exe" -ArgumentList "install dotnetfx -s $PACKAGE_DIR;$CHOCO_REPO --no-progress -r -y" -NoNewWindow -Wait
    
    # Install GRID Driver for G4dn instance type
    If ($image_id -match "Graphics-G4dn"){G4dn}

    # Add SYSTEM to SeCreateSymbolicLinkPrivilege
    Symlinks
    
    # Make directory for image builder runner
    New-Item -Path "$env:ProgramFiles" -Name "ImageBuilder" -ItemType "directory"
    
    # Download ImageBuild Program
    $URI = "https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/$package_branch/program.ps1"
    Start-BitsTransfer -Source $URI -Destination "$env:ProgramFiles\ImageBuilder\program.ps1"

}
else {
    # No Path set for SYSTEM so move to BUILD_DIR
    Set-Location $BUILD_DIR
}

# Run ImageBuilder
If ([System.Environment]::GetEnvironmentVariable("AoD_Manual", 'Machine') -ne $true){
    Write-Output "Running ImageBuilder"
    & "$env:ProgramFiles\ImageBuilder\program.ps1"
}
Else {
    If (!(test-path $DRIVER_LOCK)){New-Item -Path $DRIVER_LOCK -Force; Start-Process 'shutdown.exe' -ArgumentList '/r /f /t 0'}
    Else{    
        $URI = "https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/master/packages/troubleshooting.ps1"
        Start-BitsTransfer -Source $URI -Destination "$env:PUBLIC\Desktop\troubleshooting.ps1"
    
        # Create executable shortcut
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$env:public\desktop\troubleshooting.lnk")
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments =  "-Command `"& $env:public\desktop\troubleshooting.ps1`""
        $Shortcut.Save()
    }
}
