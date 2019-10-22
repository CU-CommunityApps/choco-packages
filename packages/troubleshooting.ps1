#######################################################################
## Script for troubleshooting .nupkg apps prior to building an image ##
#######################################################################
Write-Host "Checking admin mode..." -ForegroundColor Yellow
If ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") -ne $true){Write-Host "Please run app tests in Administrative mode" -ForegroundColor Red;exit 1}
Write-Host "Installing pre-reqs..." -ForegroundColor Yellow
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path += "$env:ALLUSERSPROFILE\chocolatey\bin"
Invoke-Expression "choco.exe upgrade -y chocolatey"
Invoke-Expression "choco.exe install -y 7zip"
Install-Module powershell-yaml -Force
Install-Module pssqlite -Force
Import-Module powershell-yaml -Force
Import-Module pssqlite -Force
$app = Read-Host "Enter app name and version (ie. adobedcreader-cornell.2018.011.20055)"
$branch = Read-Host "Enter test branch name"
$appName = $app.Split(".")[0]
$output = "c:\users\$env:USERNAME\desktop\$app.nupkg"
$extract = "c:\users\$env:USERNAME\desktop\$app"

If (!(test-path $output)){
    try{
        $URI = "https://image-build-113704540485-us-east-1.s3.amazonaws.com/packages/$branch/$app.nupkg"
        Start-BitsTransfer -Source $uri -Destination $output
    }
    catch{Write-Host "Error downloading, try again..."}
}

If ((get-item $output).Length -gt 2gb){Invoke-Expression "choco.exe install -y $output --force --debug --cache-location=C:\Temp"}
Else{Invoke-Expression "choco.exe install -y $output --force --debug --cache-location="}

Do{$ans = Read-Host "Extract and troubleshoot $app ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

If ($ans.ToLower() -eq "y"){
    Invoke-Expression "7z e $output -y -o$extract -r"
    Write-Host "Files extracted to $extract, edit config.yml and others as needed" -ForegroundColor Yellow
}
Else {Write-host "Happy testing!!" -ForegroundColor Green}

Do{$ans = Read-Host "Test $app ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

If ($ans.ToLower() -eq "y"){
    Invoke-Expression "$extract\chocolateyinstall.ps1 -Mode T -S3 image-build-113704540485-us-east-1 -App $appName" 
}
Else {Write-host "Happy testing!!" -ForegroundColor Green}
