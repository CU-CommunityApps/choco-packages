[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$USER_DATA_URI = "http://169.254.169.254/latest/user-data"
$BUCKET_PREFIX = "image-build-package-bucket"
$BUILD_DIR = Join-Path $Env:TEMP "image-build"
$PACKAGE_DIR = Join-Path $BUILD_DIR "packages"
$CHOCO_REPO = "https://chocolatey.org/api/v2"
$BUILDER_PACKAGE = "image-builder-cornell"
$BUILDER_VERSION = "1.0"

if (-Not (Test-Path $BUILD_DIR)) {
    
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
Start-Process -FilePath "PsExec.exe" -ArgumentList "-w $BUILD_DIR -i -s ImageBuilder.exe" -NoNewWindow -Wait