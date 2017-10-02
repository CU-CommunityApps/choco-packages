$packageName= 'papercut-cornell'
$toolsDir   = "C:\Windows\Temp\$packageName"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

$packageArgs = @{
	packageName = $packageName
	fileType    = 'msi'
	file        = "$toolsDir\pc-client-admin-deploy.msi"
	silentArgs  = "/qb /norestart ALLUSERS=1"
}

Install-ChocolateyInstallPackage @packageArgs  

$TargetFile = "C:\Program Files (x86)\PaperCut MF Client\pc-client.exe"
$ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\pc-client.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
