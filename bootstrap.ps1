$winTemp = "C:\Windows\Temp"
Set-Location $winTemp

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

$url = "http://169.254.169.254/latest/user-data"
$userdata = ((New-Object System.Net.WebClient).DownloadString('$url')) | ConvertFrom-Json
$arn,$builder_name = $userdata.resourceArn.split('/')

$url = "https://s3.amazonaws.com/cu-deng-appstream-packages/build/$builder_name.json"
$image_config = ((New-Object System.Net.WebClient).DownloadString('$url')) | ConvertFrom-Json
$packages = $image_config.packages -join ' '

Log-Write -LogString "Retrieved Package List for this build from S3: $builder_name, $packages"

$psexec = "C:\ProgramData\chocolatey\bin\PsExec.exe"

Start-Process -FilePath $psexec -ArgumentList "-i -s $choco install $packages -s '$winTemp;https://chocolatey.org/api/v2' -y" -NoNewWindow -Wait

Log-Write -LogString "Installed Choco Packages: $packages"
