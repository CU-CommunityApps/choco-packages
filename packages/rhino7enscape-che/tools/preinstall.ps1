# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# 2005 = v.8
# 2008 = v.9
# 2010 = v.10
# 2012 = v.11
# 2013 = v.12
# 2015 = v.14
$vers = @("8", "9", "10", "12", "14")

ForEach ($ver in $vers) {

    # Get uninstall info for each possible application
    If (!(gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
    gp | where {($_.DisplayName -match "Microsoft Visual C") -and (($_.DisplayVersion).StartsWith("$ver."))})){

        If ($ver -eq "8"){write-output "$ver not found, installing...";Start-Process "$INSTALL_DIR\redist\VC2005_redist_x64.exe" -ArgumentList "/Q" -Wait}
       # If ($ver -eq "10"){write-output "$ver not found, installing...";Start-Process "$INSTALL_DIR\redist\VC2010_redist_x64.exe" -ArgumentList "/q /norestart" -Wait}
        If ($ver -eq "12"){write-output "$ver not found, installing...";Start-Process "$INSTALL_DIR\redist\VC2013_redist_x64.exe" -ArgumentList "/install /quiet /norestart" -Wait}
        If ($ver -eq "14"){write-output "$ver not found, installing...";Start-Process "$INSTALL_DIR\redist\VC2015_redist_x64.exe" -ArgumentList "/q /norestart" -Wait}
        
    }

}
