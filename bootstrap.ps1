[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$USER_DATA_URI = "http://169.254.169.254/latest/user-data"
$BUCKET_PREFIX = "image-build-package-bucket"
$BUILD_DIR = Join-Path $Env:TEMP "image-build"
$PACKAGE_DIR = Join-Path $BUILD_DIR "packages"
$CHOCO_REPO = "https://chocolatey.org/api/v2"
$BUILDER_PACKAGE = "image-builder-cornell"
$BUILDER_VERSION = "1.0"

if (-Not (Test-Path $BUILD_DIR)) {
    
    # Create Temp Folders
    New-Item -ItemType Directory -Force -Path $BUILD_DIR
    New-Item -ItemType Directory -Force -Path $PACKAGE_DIR
    
    # Parse EC2 User Data
    $raw_user_data = (Invoke-WebRequest $USER_DATA_URI).Content
    $user_data = [System.Text.Encoding]::ASCII.GetString($raw_user_data) | ConvertFrom-Json
    $arn = $user_data.resourceArn.split(':')
    $region = $arn[3]
    $account = $arn[4]
    $builder = $arn[5].split('/')[1].split('.')
    $package_branch = $builder[1]
    $build_id = $builder[2]
    $bucket = "$BUCKET_PREFIX-$account-$region"
    $build_package_uri = "https://s3.amazonaws.com/$bucket/packages/$package_branch/$BUILDER_PACKAGE.$BUILDER_VERSION.nupkg"
    
    # Download ImageBuilder Nupkg
    Invoke-WebRequest $build_package_uri -OutFile (Join-Path "$PACKAGE_DIR" "$BUILDER_PACKAGE.$BUILDER_VERSION.nupkg")
    
    # Install Chocolatey
    Invoke-Expression ((Invoke-WebRequest "https://chocolatey.org/install.ps1").Content)
    
    # Install ImageBuilder and Sysinternals
    Start-Process -FilePath "choco.exe" -ArgumentList "install $BUILDER_PACKAGE sysinternals -s $PACKAGE_DIR;$CHOCO_REPO -y" -NoNewWindow -Wait
}

# Run ImageBuilder
Start-Process -FilePath "PsExec.exe" -ArgumentList "-w $BUILD_DIR -i -s ImageBuilder.exe" -NoNewWindow -Wait