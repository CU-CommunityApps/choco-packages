$packageName= 'appstream-scripts'
$toolsDir   = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

choco install python2 -y
pip install boto3

Install-ChocolateyZipPackage $packageName $url $toolsDir

New-Item C:\Scripts -type directory
Copy-Item $toolsDir\user-monitoring.py C:\Scripts
Copy-Item $toolsDir\.aws "C:\Users\Default" -recurse
