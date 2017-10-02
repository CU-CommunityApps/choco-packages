$packageName= 'solidworks-coecis'
$toolsDir   = $env:TEMP
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

Add-WindowsFeature NET-Framework-Core

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\startswinstall.exe"
	silentArgs  = "/install /showui /now"
}

Install-ChocolateyInstallPackage @packageArgs  
