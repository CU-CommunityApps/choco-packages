$ErrorActionPreference = "Stop"

$PACKAGE =      "{Package}"
$BUCKET =       "{Bucket}"
$INSTALLER =    "{Installer}"
$FILETYPE =     "{FileType}"
$ARGUMENTS =    "{Arguments}"
$VALID_CODES =  "{ValidCodes}"
$INSTALL_DIR =  Join-Path $env:TEMP $PACKAGE
$S3_URI =       "https://s3.amazonaws.com/$BUCKET/packages/$PACKAGE.zip"

Write-Output "Unzipping $PACKAGE From $S3_URI"
Install-ChocolateyZipPackage -PackageName $PACKAGE -Url $S3_URI -UnzipLocation $INSTALL_DIR

Write-Output "Running preinstall.ps1"
Invoke-Expression '.\preinstall.ps1'

$packageArgs = @{{
    packageName=$PACKAGE
    fileType=$FILETYPE
    file=$INSTALLER
    silentArgs=$ARGUMENTS
    validExitCodes=@($VALID_CODES) 
}}

Write-Output "Installing $PACKAGE With Args: $packageArgs"
Install-ChocolateyInstallPackage @packageArgs

Write-Output "Running postinstall.ps1"
Invoke-Expression '.\postinstall.ps1'

Write-Output "$PACKAGE Install Complete!"

