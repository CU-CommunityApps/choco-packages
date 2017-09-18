$packageName= 'solidworks-coecis'
#$toolsDir   = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$toolsDir   = "C:\SOLIDWORKS"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

Add-WindowsFeature NET-Framework-Core
#Start-Process -FilePath msiexec.exe -ArgumentList "/package `"$toolsDir\64bit\Microsoft_VBA\vba71.msi`" /passive" -NoNewWindow -Wait
#Start-Process -FilePath msiexec.exe -ArgumentList "/package `"$toolsDir\64bit\RemoteDebugger\rdbgexp.msi`" /passive" -NoNewWindow -Wait

$serial = Get-Content "$toolsDir\serial.txt"

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\startswinstall.exe"
	silentArgs  = "/install /showui /now"
}

Install-ChocolateyInstallPackage @packageArgs  
