# Runs after the choco package is installed
# Runs after the choco package is installed
Start-Process -licenseactivator "%SYSTEMDRIVE%\Program Files\IBM\SPSS\Statistics\25\licenseactivator.exe" [-licensecode=%SPSS_LICENSE_KEY%"

