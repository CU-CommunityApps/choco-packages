$packageName= 'ansys-coecis'
$toolsDir   = "C:\Windows\Temp"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\setup.exe"
	silentArgs  = "-silent -licserverinfo 2325:1055:ansys-lic.coecis.cornell.edu"
}

Install-ChocolateyInstallPackage @packageArgs  
