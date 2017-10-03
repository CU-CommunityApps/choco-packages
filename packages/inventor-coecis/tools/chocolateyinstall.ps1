$packageName= 'inventor-coecis'
$toolsDir   = "C:\Windows\Temp\$packageName"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\Img\Setup.exe"
	silentArgs  = "/qr /I $toolsDir\Img\inventor-coecis.ini /language en-us"
    validExitCodes = @(0, 259)
}

[Environment]::SetEnvironmentVariable("ADSKFLEX_LICENSE_FILE", "27200@autodesk-lic.coecis.cornell.edu", "Machine")

Install-ChocolateyInstallPackage @packageArgs  
