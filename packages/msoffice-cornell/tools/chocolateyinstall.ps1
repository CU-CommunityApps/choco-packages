$packageName= 'msoffice-cornell'
$toolsDir   = "C:\Windows\Temp\$packageName"
$sqlite     = "C:\ProgramData\chocolatey\bin\sqlite3.exe"
$appCatalog = "C:\ProgramData\Amazon\Photon\PhotonAppCatalog.sqlite"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $toolsDir

Add-WindowsFeature NET-Framework-Core

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$toolsDir\setup.exe"
	silentArgs  = "/adminfile $toolsDir\cu_office_config.MSP"
}

Install-ChocolateyInstallPackage @packageArgs  

# Add AppStream related items
Copy-Item "$toolsDir\appstream\icons\*" "C:\ProgramData\Amazon\Photon\AppCatalogHelper\AppIcons"
Start-Process -FilePath $sqlite -ArgumentList "$appCatalog `".read $toolsDir\appstream\catalog.sql`"" -NoNewWindow -Wait

#$officePath = (Get-ItemProperty "hklm:\software\microsoft\windows\currentversion\app paths\WINWORD.EXE").Path

#echo "Activating MS Office..."
#$result = & cscript ${officePath}ospp.vbs /sethst:kms02.cit.cornell.edu | Out-String
#echo $result
#$result = & cscript ${officePath}ospp.vbs /act | Out-String
#echo $result
