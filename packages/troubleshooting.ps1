<#
.SYNOPSIS
    Chocolatey .nupkg troubleshooting script
.DESCRIPTION
    Test custom .nupkg installers on Windows OS' prior to building an AppStream image
.PARAMETER s3
    S3 bucket name for installer files. Bucket name only, do not include entire path. i.e. if S3 bucket path is https://s3.amazonaws.com/mybucket input 'mybucket' - Required
.PARAMETER package
    Application name for testing (ie. adobedcreader-cornell) - Optional
.PARAMETER branch
    Test branch name (ie. adobedcreader) - Optional
.EXAMPLE
    PS C:\Users\test\Desktop> 
    .\troubleshooting.ps1 -s3 somebucketname -package adobedcreader-cornell -branch adobedcreader
.EXAMPLE
    PS C:\Users\test\Desktop> 
    .\troubleshooting.ps1 -s3 somebucketname
.LINK
    https://github.com/CU-CommunityApps/choco-packages
    https://confluence.cornell.edu/display/CLOUD/Cornell+Stream
    https://developer.github.com/v3/
.NOTES
    Testing should occur on same OS as target OS.
    irm -uri "https://api.github.com/repos/CU-CommunityApps/choco-packages" to see available github parameters
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false,Position=1,HelpMessage="S3 bucket name containing .nupkg files")]
    [ValidateNotNullOrEmpty()]
    [string]$s3,
    [Parameter(Mandatory=$false,Position=2,HelpMessage="Application name")]
    [ValidateNotNullOrEmpty()]
    [string]$package,
    [Parameter(Mandatory=$false,Position=3,HelpMessage="Test branch name")]
    [ValidateNotNullOrEmpty()]
    [string]$branch
)

try {
    
    Write-Host "Checking system for bucket information..."

    $user_data_uri = "http://169.254.169.254/latest/user-data"
    $bucket_prefix = "image-build"
    $user_data = (irm -Uri $user_data_uri).resourceARN
    $region = $user_data.Split(":")[3]
    $account = $user_data.Split(":")[4]
    $build_id = $user_data.Split(":")[5].Split("/")[1]
    $package_branch = $build_id.Split(".")[1]
    $image_id = $build_id.Split(".")[2..$build_id.Split(".").Length] -join "."
    $s3 = "$bucket_prefix-$account-$region"

    Write-Host "Bucket found, $s3" -ForegroundColor Green

}
catch{
    
    Write-Host "System is not an AppStream Image Builder!" -ForegroundColor Red
    $s3 = Read-Host "Enter S3 package bucket name"

    Do{$ans = Read-Host "You entered $s3, is this correct (ie. y or n)?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "yes"))

}

# Must run in Administrator Mode
Write-Host "Checking admin mode..." -ForegroundColor Yellow
If ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") -ne $true){Write-Host "Please run app tests in Administrative mode" -ForegroundColor Red;exit 1}
Write-Host "Installing pre-reqs..." -ForegroundColor Yellow
# Download and install Chocolatey
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Add choco.exe to user path
$env:Path += "$env:ALLUSERSPROFILE\chocolatey\bin"
# Upgrade chocolatey to latest version
Invoke-Expression "choco.exe upgrade -y chocolatey"
# Install 7-zip
Invoke-Expression "choco.exe install -y 7zip"
# Install required powershell modules
If ((Get-Module powershell-yaml, pssqlite).Count -eq 2){Write-Host "Powershell modules already installed" -ForegroundColor Green}
Else {Install-PackageProvider -Name nuget -MinimumVersion 2.8.5.201 -Force;Install-Module powershell-yaml -Force; Install-Module pssqlite -Force; Import-Module powershell-yaml -Force; Import-Module pssqlite -Force}

$repo = "CU-CommunityApps/choco-packages"
$apiURI = "https://api.github.com/repos/$repo"
$rawURI = "https://raw.githubusercontent.com/$repo"

Function branches {

    # List current branches
    Write-Host "`nCurrent branches for $repo`n" -ForegroundColor Yellow
    $branches = (irm -uri "$apiURI/branches").name
    $branches | select | where {$_ -NE "master"}
    
    Do {
        $branch = Read-Host "`nSelect branch"
    }Until ($branches -contains $branch)

    packages $branch
}

Function packages($branch) {

    # List packages
    Write-Host "`nCurrent packages on $branch branch`n" -ForegroundColor Yellow
    $packages = (irm -Uri "$apiURI/contents/packages?ref=$branch")
    $packages.name | select | where {$_ -match "-"}

    Do {
        $package = Read-Host "`nSelect package"
    }Until ($packages.name -contains $package)

    $package

    version $package $branch   

}

Function version($package, $branch){

    # Get file version
    $config = irm -Uri "$rawURI/$branch/packages/$package/config.yml"
    $config
    $version = ($config | ConvertFrom-Yaml).version

    troubleshoot $package $branch $version

}

Function troubleshoot($package, $branch, $version) {

    # Download and extract locations on test machine
    $output = "$env:USERPROFILE\Desktop\$package.$version.nupkg"
    $extract = "$env:USERPROFILE\Desktop\$package.$version"

    # If the file doesn't exist, download from S3 bucket
    If (!(test-path $output)){
        try{
            $URI = "https://$s3.s3.amazonaws.com/packages/$branch/$package.$version.nupkg"
            Start-BitsTransfer -Source $URI -Destination $output -ErrorAction Stop
        }
        catch{Write-Host "$package.$version has not been built yet or does not exist, commit to github and wait for successful build, then try again! Verify your IP address is within the approved range as well..." -ForegroundColor Red;branches}
    }

    # Cache process to disk if file is greater than 2GB
    If ((get-item $output).Length -gt 2gb){Invoke-Expression "choco.exe install -y $output --force --debug --cache-location=C:\Temp"}
    Else{Invoke-Expression "choco.exe install -y $output --force --debug --cache-location="}

    Do{$ans = Read-Host "Extract and troubleshoot $package.$version ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

    If ($ans.ToLower() -eq "y"){
        Invoke-Expression "7z e $output -y -o$extract -r"
        Write-Host "Files extracted to $extract, edit config.yml and others as needed" -ForegroundColor Yellow
        
        pause

        Do{$ans = Read-Host "Test $package.$version ?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

        If ($ans.ToLower() -eq "y"){
            Invoke-Expression "$extract\chocolateyinstall.ps1 -Mode T -S3 $s3 -App $package" 
        }
        Else {
            Do{$ans = Read-Host "Test another application?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

            If ($ans.ToLower() -eq "y"){branches}
            Else {Write-host "Happy testing!!" -ForegroundColor Green; exit 0}
        }
    }
    Else {
        Do{$ans = Read-Host "Test another application?"}Until(($ans.ToLower() -eq "y") -or ($ans.ToLower() -eq "n"))

        If ($ans.ToLower() -eq "y"){branches}
        Else {Write-host "Happy testing!!" -ForegroundColor Green; exit 0}
    }

}

If ($package -and $branch){version $package $branch}
Else {branches}
