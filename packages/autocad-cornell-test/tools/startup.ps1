## Register and activate license per streaming session
# Paths
$helperPath  = "${env:CommonProgramFiles(x86)}\Autodesk Shared\AdskLicensing\Current\helper\AdskLicensingInstHelper.exe"
$configFile  = "$env:ProgramData\Autodesk\Product Information\AutoCADConfig.pit"
# License settings
$prodKey     = "001R1"
$prodVer     = "2026.0.0.F"
$licMethod   = "NETWORK"
$licServers  = "$env:ADSKFLEX_LICENSE_FILE"
# Build argument string
$arguments = @(
    'register'
    "--prod_key `"$prodKey`""
    "--prod_ver `"$prodVer`""
    "--lic_method `"$licMethod`""
    "--lic_servers `"$licServers`""
    "--config_file `"$configFile`""
) -join ' '
Start-Process -FilePath $helperPath -ArgumentList $arguments -NoNewWindow -Wait