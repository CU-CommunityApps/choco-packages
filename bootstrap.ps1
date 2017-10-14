$winTemp = "C:\Windows\Temp"
Set-Location $winTemp
$packageRepo = "https://github.com/CU-CommunityApps/choco-packages.git"
$choco = "C:\ProgramData\chocolatey\bin\choco.exe"
$chocoPrereqs = "git sysinternals sqlite notepadplusplus 7zip googlechrome"
$sqlite = "C:\ProgramData\chocolatey\bin\sqlite3.exe"
$appCatalog = "C:\ProgramData\Amazon\Photon\PhotonAppCatalog.sqlite"
$appCatalogSql = "CREATE TABLE Applications (Name TEXT NOT NULL CONSTRAINT PK_Applications PRIMARY KEY, AbsolutePath TEXT, DisplayName TEXT, IconFilePath TEXT, LaunchParameters TEXT, WorkingDirectory TEXT);"
$appIconPath = "C:\ProgramData\Amazon\Photon\AppCatalogHelper\AppIcons"
$LogFile = "$winTemp\image-builder.log"

# Create Logging Function
Function Log-Write ([String] $LogString){
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    Add-Content $LogFile -value "$Stamp $LogString"
}

Log-Write -LogString "Bootstrapping Choco and Installing: $packages"
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Log-Write -LogString "Installed Choco"

# Install some Choco prerequisites
Start-Process -FilePath $choco -ArgumentList "config set cacheLocation $winTemp\chococache"
Start-Process -FilePath $choco -ArgumentList "install $chocoPrereqs -y" -NoNewWindow -Wait

if (Test-Path "$winTemp\choco-packages") {
    Remove-Item -Recurse -Force "$winTemp\choco-packages"
}

Log-Write -LogString "Installed Choco Prerequisites"

# Clone the Choco Package Repo and compile NuGet Packages
Start-Process -FilePath "C:\Program Files\Git\bin\git.exe" -ArgumentList "clone $packageRepo $winTemp\choco-packages" -NoNewWindow -Wait

$packageDirs = dir "$winTemp\choco-packages\packages" | ?{$_.PSISContainer}
foreach ($d in $packageDirs) {
	$nuspec = Join-Path -Path $d.FullName -ChildPath ($d.Name + ".nuspec")
	Start-Process -FilePath $choco -ArgumentList "pack $nuspec --out $winTemp -y" -NoNewWindow -Wait
}

Log-Write -LogString "Compiled Choco Packages in $packageRepo"

# Create AppStream Application Catalog database
if (Test-Path $appCatalog) {
    Remove-Item $appCatalog
}

if (!(Test-Path $appIconPath)) {
    New-Item -ItemType Directory -Force -Path $appIconPath
}

Start-Process -FilePath $sqlite -ArgumentList "$appCatalog `"$appCatalogSql`"" -NoNewWindow -Wait
Log-Write -LogString "Created Empty AppStream Application Catalog"

# Get Current AutoDeploy Configuration from S3
$url = "http://169.254.169.254/latest/user-data"
$userdata = ((New-Object System.Net.WebClient).DownloadString($url)) | ConvertFrom-Json
$arn,$builder_name = $userdata.resourceArn.split('/')

$url = "https://s3.amazonaws.com/cu-deng-appstream-packages/build/$builder_name.json"
$image_config = ((New-Object System.Net.WebClient).DownloadString($url)) | ConvertFrom-Json
$packages = $image_config.packages -join ' '

Log-Write -LogString "Retrieved Package List for this build from S3: $builder_name, $packages"

# Install Packages
$psexec = "C:\ProgramData\chocolatey\bin\PsExec.exe"

Start-Process -FilePath $psexec -ArgumentList "-i -s $choco install $packages -s '$winTemp;https://chocolatey.org/api/v2' -y" -NoNewWindow -Wait

Log-Write -LogString "Installed Choco Packages: $packages"
