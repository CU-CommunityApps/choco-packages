$packageName= 'papercut-cornell'
$toolsDir   = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

$packageArgs = @{
	packageName = $packageName
	fileType    = 'msi'
	file        = "$toolsDir\pc-client-admin-deploy.msi"
	silentArgs  = "/qb /norestart ALLUSERS=1"
}

Install-ChocolateyInstallPackage @packageArgs  
