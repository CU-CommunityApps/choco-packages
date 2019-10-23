<#
.SYNOPSIS
    Chocolatey .nupkg troubleshooting script
.DESCRIPTION
    Test custom .nupkg installers on Windows OS' prior to building an AppStream image
.PARAMETER S3
    S3 bucket name for installer files. Bucket name only, do not include entire path. i.e. if S3 bucket path is https://s3.amazonaws.com/mybucket input 'mybucket'
.PARAMETER App_Version
    Application name and version number for testing (ie. adobedcreader-cornell.2018.011.20055)
.PARAMETER Branch
    Test branch name (ie. adobedcreader)
.EXAMPLE
    PS C:\Users\test\Desktop> 
    .\troubleshooting.ps1 -S3 somebucketname -App_Version adobedcreader-cornell.2018.011.20055 -Branch adobedcreader
.LINK
    https://github.com/CU-CommunityApps/choco-packages
    https://confluence.cornell.edu/display/CLOUD/Cornell+Stream
.NOTES
    Testing should occur on same OS as target OS.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="S3 bucket name containing .nupkg files")]
    [ValidateNotNullOrEmpty()]
    [string]$S3,
    [Parameter(Mandatory=$true,Position=2,HelpMessage="Application name and version number")]
    [ValidateNotNullOrEmpty()]
    [string]$App_Version,
    [Parameter(Mandatory=$true,Position=3,HelpMessage="Test branch name")]
    [ValidateNotNullOrEmpty()]
    [string]$Branch
)

# Must run in Administrator Mode
Write-Host "Checking admin mode..." -ForegroundColor Yellow
If ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") -ne $true){Write-Host "Please run app tests in Administrative mode" -ForegroundColor Red;exit 1}
Write-Host "Installing pre-reqs..." -ForegroundColor Yellow
# Download and install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Add choco.exe to user path
$env:Path += "$env:ALLUSERSPROFILE\chocolatey\bin"
# Upgrade chocolatey to latest version
Invoke-Expression "choco.exe upgrade -y chocolatey"
# Install 7-zip
Invoke-Expression "choco.exe install -y 7zip"
# Install required powershell modules
Install-Module powershell-yaml -Force
Install-Module pssqlite -Force
# Import required powershell modules
Import-Module powershell-yaml -Force
Import-Module pssqlite -Force

# Variables
$appName = $App_Version.Split(".")[0]
$output = "$env:USERPROFILE\Desktop\$App_Version.nupkg"
$extract = "$env:USERPROFILE\Desktop\$App_Version"

# If the file doesn't exist, download from S3 bucket
If (!(test-path $output)){
    try{
        $URI = "https://$S3.s3.amazonaws.com/packages/$branch/$App_Version.nupkg"
        Start-BitsTransfer -Source $uri -Destination $output
    }
    catch{Write-Host "Error downloading, try again..."}
}

# Cache process to disk if file is greater than 2GB
If ((get-item $output).Length -gt 2gb){Invoke-Expression "choco.exe install -y $output --force --debug --cache-location=C:\Temp"}
Else{Invoke-Expression "choco.exe install -y $output --force --debug --cache-location="}

Do{$ans = Read-Host "Extract and troubleshoot $App_Version ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

If ($ans.ToLower() -eq "y"){
    Invoke-Expression "7z e $output -y -o$extract -r"
    Write-Host "Files extracted to $extract, edit config.yml and others as needed" -ForegroundColor Yellow
}
Else {Write-host "Happy testing!!" -ForegroundColor Green}

Do{$ans = Read-Host "Test $App_Version ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

If ($ans.ToLower() -eq "y"){
    Invoke-Expression "$extract\chocolateyinstall.ps1 -Mode T -S3 $S3 -App $appName" 
}
Else {Write-host "Happy testing!!" -ForegroundColor Green}
