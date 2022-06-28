# AutoDesk license installer helper

$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# ADSK installation location
$exe = "${env:CommonProgramFiles(x86)}\Autodesk Shared\AdskLicensing\Current\helper\AdskLicensingInstHelper.exe"

# SYSTEM environment variable registry key
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

# AutoDesk product key (product identifier - ie. Revit, AutoCAD, 3dsMax, etc...)
# 00101 = AutoCAD 202
# 12801 = 3dsMax 2023
$productKey = "12801"

# AutoDesk product version
$productVer = "2023.1"

# AutoDesk Product Info file location
$configFile = "$env:ALLUSERSPROFILE\autodesk\Adlm\ProductInformation.pit"

# Get parent process environment variable(s)
$ADSKFLEX_LIC_FILE = Get-ItemPropertyValue $regKey -Name "ADSKFLEX_LICENSE_FILE"

# Get license server (this environment variable is specific to Apps on Demand)
$licServer = $ADSKFLEX_LIC_FILE.Split("@")[1].Split(";")[0]

# Get IP address of license server
$serverAddress = "@" + (Resolve-DnsName $licServer).IP4Address

# Adsk License Helper help doc

<###
.\AdskLicensingInstHelper.exe register --help
NAME:
   AdskLicensingInstHelper.exe register - Register product with the licensing components. Requires admin rights
USAGE:
   AdskLicensingInstHelper.exe register [command options]
   Legend:
     [R] - required
     [O] - optional
OPTIONS:
   --prod_key key, --pk key             [R] key of the product to register (e.g. "001K1")
   --prod_ver version, --pv version     [R] version of the product to register (e.g. "2019.0.0.F")
   --config_file path, --cf path        [R] product's PIT config file path
   --eula_locale value, --el value      [O] EULA locale (e.g. "US")
   --feature_id key, --fi key           [O] alternate key of the product to register (e.g. "ACD", for license method USER only)
   --lic_method value, --lm value       [O] Selected license method during install. Should be one of (case insensitive): USER, STANDALONE, NETWORK
   --lic_server_type value, --lt value  [O] network license server type. Should be one of (case insensitive): SINGLE, REDUNDANT, DISTRIBUTED
   --lic_servers value, --ls value      [O] list of comma separated network license server addresses. For example: @127.0.0.1,@192.168.1.1,@9.0.9.0
   --serial_number value, --sn value    [O] serial number to register the product with (default 000-00000000)
   --sel_prod_key key, --sk key         [O] selected key for products installed as a bundle or suite (e.g. "784K1")
   --no_user_license, --nu              [O] set if this product does not want to support user licensing
   --consumers value, --co value        [O] comma-separated identifiers of products consuming the feature
###>

# Register product license type
$args = "register --pk $productKey --pv $productVer --cf $configFile --el US --lm NETWORK --ls $serverAddress"

# Run the license helper
Start-Process $exe -ArgumentList $args -Verbose

# Install security component add on
Start-Process "msiexec.exe" -ArgumentList "/i $INSTALL_DIR\3dsmax-component-security-tools2022-2.1.0-021.msi /qn"
