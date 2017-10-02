$packageName= 'ces-edupack-coecis'
$toolsDir   = "C:\Windows\Temp\$packageName"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\edupack_setup.2017.exe"
	silentArgs  = "/quiet"
}

Install-ChocolateyInstallPackage @packageArgs  
