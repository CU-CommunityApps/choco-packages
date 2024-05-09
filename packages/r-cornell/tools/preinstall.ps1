# Runs before the choco package is installed

#Download latest version of R

$url = "https://cloud.r-project.org//bin/windows/base/$((Invoke-WebRequest https://cloud.r-project.org/bin/windows/base/ | Select -ExpandProperty Links | Where innerText -like "Download R*for Windows")[0].href)"

Start-BitsTransfer $url -Destination "$PSScriptRoot\RInstall.exe"

#R installs to a version specific directory, so we need to find the version information of the .exe

$version = ((Get-ItemProperty "$PSScriptRoot\RInstall.exe").VersionInfo.ProductVersion).Trim()

# Now we go up one level to dynamically update the config.yaml to have the correct version

$yamlFilePath = "$PSScriptRoot\config.yml"

# Read the content of the YAML file
$fileContent = Get-Content -Path $yamlFilePath -Raw

# Search for the word "#VERSION#" and replace it with "4.4.0"
$newContent = $fileContent -replace "000.000.000", "$version"

# Write the updated content back to the YAML file
$newContent | Set-Content -Path $yamlFilePath

