$packageName= 'msoffice-cornell'
$toolsDir   = $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
$tempDir    = "C:\Windows\Temp\$packageName"
$sqlite     = "C:\ProgramData\chocolatey\bin\sqlite3.exe"
$appCatalog = "C:\ProgramData\Amazon\Photon\PhotonAppCatalog.sqlite"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

Install-ChocolateyZipPackage $packageName $url $tempDir

Add-WindowsFeature NET-Framework-Core

$packageArgs = @{
	packageName = $packageName
	fileType    = 'exe'
	file        = "$tempDir\setup.exe"
	silentArgs  = "/adminfile $tempDir\cu_office_config.MSP"
}

Install-ChocolateyInstallPackage @packageArgs  

# Add AppStream related items
$escapedPath = "$toolsDir\appstream\catalog.sql" -replace '\\', '\\'
Copy-Item "$toolsDir\appstream\icons\*" "C:\ProgramData\Amazon\Photon\AppCatalogHelper\AppIcons"
Start-Process -FilePath $sqlite -ArgumentList "$appCatalog `".read $escapedPath`"" -NoNewWindow -Wait

$officePath = (Get-ItemProperty "hklm:\software\microsoft\windows\currentversion\app paths\WINWORD.EXE").Path

echo "Activating MS Office..."
result = & cscript ${officePath}ospp.vbs /sethst:kms02.cit.cornell.edu | Out-String
echo $result
$result = & cscript ${officePath}ospp.vbs /act | Out-String
echo $result
