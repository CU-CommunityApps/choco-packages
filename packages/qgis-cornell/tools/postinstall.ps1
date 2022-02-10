# Runs after the choco package is installed
#Invoke-WebRequest https://ubuntu.qgis.org/version.txt -UseBasicParsing

# List of applications to remove
# 2005 = 8
# 2008 = 9
# 2010 = 10
# 2012 = 11
$vers = @("8", "9")

ForEach ($ver in $vers) {

    # Get uninstall info for each possible application
    If (gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
    gp | where {($_.DisplayName -match "Microsoft Visual C") -and (($_.DisplayVersion).StartsWith("$ver."))}){

        $install = gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | `
        gp | where {($_.DisplayName -match "Microsoft Visual C") -and (($_.DisplayVersion).StartsWith("$ver."))} | select DisplayName, InstallLocation, UninstallString
    
        If ($install.UninstallString -match "/X"){
            write-host $install.UninstallString
            $install.UninstallString = $install.UninstallString.Substring($install.UninstallString.IndexOf("/X")+2).Trim()
            write-host $install.UninstallString
        }
        Start-Process "msiexec.exe" -ArgumentList "/x $($install.UninstallString) /q" -Wait
    }

}
