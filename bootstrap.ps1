$packageRepo = "https://github.com/CU-CommunityApps/choco-packages.git"
$choco = "C:\ProgramData\chocolatey\bin\choco.exe"
$tempDir = $env:TEMP
cd $tempDir

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Start-Process -FilePath $choco -ArgumentList "install git -y" -NoNewWindow -Wait
Start-Process -FilePath "C:\Program Files\Git\bin\git.exe" -ArgumentList "clone $packageRepo $tempDir\choco-packages" -NoNewWindow -Wait

$packageDirs = dir "$tempDir\choco-packages" | ?{$_.PSISContainer}
foreach ($d in $packageDirs) {
	$nuspec = Join-Path -Path $d.FullName -ChildPath ($d.Name + ".nuspec")
	Start-Process -FilePath $choco -ArgumentList "pack $nuspec -y" -NoNewWindow -Wait
}
