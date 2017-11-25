#$ErrorActionPreference = "Stop"

$PACKAGE =      "{Package}"
$BUCKET =       "{Bucket}"
$INSTALLER =    "{Installer}"
$FILETYPE =     "{FileType}"
$ARGUMENTS =    "{Arguments}"
$VALID_CODES =  "{ValidCodes}"

$TEMP_DIR =     Join-Path $env:SYSTEMROOT   "Temp\choco-bootstrap"
$INSTALL_DIR =  Join-Path $TEMP_DIR         "choco-packages\$PACKAGE"
$PRE_SCRIPT =   Join-Path $INSTALL_DIR      "pre_install.ps1"
$POST_SCRIPT =  Join-Path $INSTALL_DIR      "post_install.ps1"

$S3_URI = "https://s3.amazonaws.com/$BUCKET/packages/$PACKAGE.zip"
Install-ChocolateyZipPackage $PACKAGE $S3_URI $INSTALL_DIR
Set-Location $INSTALL_DIR

Start-Process -NoNewWindow -Wait -FilePath $PRE_SCRIPT

$packageArgs = @{{
    packageName=$PACKAGE
    fileType=$FILETYPE
    file=$INSTALLER
    silentArgs=$ARGUMENTS
    validExitCodes=@($VALID_CODES) 
}}

Install-ChocolateyInstallPackage @packageArgs

Start-Process -NoNewWindow -Wait -FilePath $POST_SCRIPT

