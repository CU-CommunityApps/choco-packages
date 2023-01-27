
$SourceDir   = "$env:ALLUSERSPROFILE\chocolatey\lib\adobesuite-named-cornell\tools\Fonts\"
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)

foreach ($FontItem in (Get-ChildItem -Path $SourceDir -Include '*.ttf','*.ttc','*.otf' -Recurse))  {  
    
	# Install each font in the Fonts folder in Tools Dir
	$Destination.CopyHere($FontItem.FullName,0x10)
}