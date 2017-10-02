$packageName= 'appstream-scripts'
$toolsDir   = "C:\Windows\Temp"
$url        = "https://s3.amazonaws.com/cu-deng-appstream-packages/packages/$packageName.zip"

choco install python2 -y
#pip install boto3
Start-Process -FilePath "C:\Python27\Scripts\pip.exe" -ArgumentList "install boto3" -NoNewWindow -Wait

Install-ChocolateyZipPackage $packageName $url $toolsDir

New-Item C:\Scripts -type directory
Copy-Item $toolsDir\user-monitoring.py C:\Scripts
Copy-Item $toolsDir\.aws "C:\Users\Default" -recurse
