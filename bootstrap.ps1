[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$USER_DATA_URI = "http://169.254.169.254/latest/user-data"
$BUCKET_PREFIX = "image-build"
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


if (-Not (Test-Path $BUILD_DIR)) {

    # Wait Five Minutes on First Run
    Start-Sleep -Seconds 300

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
    Start-Process -FilePath "choco.exe" -ArgumentList "install sysinternals --no-progress -r -y" -NoNewWindow -Wait
    
    # Parse EC2 Metadata
    Write-Output "Parsing EC2 Metadata"
    $user_data = ((New-Object System.Net.WebClient).DownloadString($USER_DATA_URI)) | ConvertFrom-Json
    Write-Output "User Data: $user_data"
    $arn = $user_data.resourceArn.split(':')
    $region = $arn[3]
    $account = $arn[4]
    $builder = $arn[5].split('/')[1].split('.')
    $package_branch = $builder[1]
    $build_id = $builder[2]
    $bucket = "$BUCKET_PREFIX-$account-$region"
    $build_package_uri = "https://s3.amazonaws.com/$bucket/packages/$package_branch/$BUILDER_PACKAGE.$BUILDER_VERSION.nupkg"
    Write-Output "Build Id: $build_id; Package Branch: $package_branch; "
    
    # Download ImageBuild Package
    Write-Output "Downloading ImageBuilder Nupkg: $build_package_uri"
    (New-Object System.Net.WebClient).DownloadFile($build_package_uri, (Join-Path "$PACKAGE_DIR" "$BUILDER_PACKAGE.$BUILDER_VERSION.nupkg"))
    
    # Install ImageBuilder
    Write-Output "Installing ImageBuilder Package"
    Start-Process -FilePath "choco.exe" -ArgumentList "install $BUILDER_PACKAGE -s $PACKAGE_DIR;$CHOCO_REPO --no-progress -r -y" -NoNewWindow -Wait

}
else {
    
    # No Path set for SYSTEM so move to BUILD_DIR
    Set-Location $BUILD_DIR
}

# Run ImageBuilder
Write-Output "Running ImageBuilder"
Start-Process -FilePath "PsExec.exe" -ArgumentList "-w $BUILD_DIR -i -s ImageBuilder.exe" -RedirectStandardOutput "$BUILDER_STDOUT_LOG" -RedirectStandardError "$BUILDER_STDERR_LOG" -NoNewWindow -Wait