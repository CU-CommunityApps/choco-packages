# Runs after the choco package is installed
start-process "$env:programfiles\IBM\SPSS\Statistics\28\licenseactivator.exe" -ArgumentList "$env:SPSS_LICENSE_KEY" -wait

