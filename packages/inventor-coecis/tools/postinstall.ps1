# Runs after the choco package is installed

# Set Autodesk License Server Machine Variable
[Environment]::SetEnvironmentVariable("ADSKFLEX_LICENSE_FILE", "27200@autodesk-lic.coecis.cornell.edu", "Machine")
