# Runs after the choco package is installed
# Runs after the choco package is installed
Push-Location "$(${env:ProgramFiles})\IBM\SPSS\Statistics\25"; Invoke-Expression "& .\licenseactivator.exe %SPSS_LICENSE_KEY%"

