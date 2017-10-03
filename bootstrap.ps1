param(
    [Parameter(Mandatory=$False)]
    [String[]] $packages=@()
)

$packages = $packages -join " "

$winTemp = "C:\Windows\Temp"

$LogFile = "$winTemp\image-builder.log"

Function Log-Write ([String] $LogString){
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    Add-Content $LogFile -value "$Stamp $LogString"
}

Log-Write -LogString "Bootstrapping Choco and Installing: $packages"

$packageRepo = "https://github.com/CU-CommunityApps/choco-packages.git"
$choco = "C:\ProgramData\chocolatey\bin\choco.exe"

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Log-Write -LogString "Installed Choco"

Start-Process -FilePath $choco -ArgumentList "config set cacheLocation C:\Windows\Temp\chococache"
Start-Process -FilePath $choco -ArgumentList "install git sysinternals -y" -NoNewWindow -Wait
Remove-Item -Recurse -Force "$winTemp\choco-packages"

Log-Write -LogString "Installed Git"

Start-Process -FilePath "C:\Program Files\Git\bin\git.exe" -ArgumentList "clone $packageRepo $winTemp\choco-packages" -NoNewWindow -Wait

$packageDirs = dir "$winTemp\choco-packages\packages" | ?{$_.PSISContainer}
foreach ($d in $packageDirs) {
	$nuspec = Join-Path -Path $d.FullName -ChildPath ($d.Name + ".nuspec")
	Start-Process -FilePath $choco -ArgumentList "pack $nuspec --out $winTemp -y" -NoNewWindow -Wait
}

Log-Write -LogString "Compiled Choco Packages in $packageRepo"

Start-Process -FilePath $choco -ArgumentList "install $packages -s '$winTemp;https://chocolatey.org/api/v2' -y" -NoNewWindow -Wait

Log-Write -LogString "Installed Choco Packages: $packages"
