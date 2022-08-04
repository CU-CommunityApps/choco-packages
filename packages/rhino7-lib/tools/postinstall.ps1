# Runs after the choco package is installed

$vers = @("8", "9", "10")

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
# Remove faulty plug-in
Get-Item -Path "HKLM:\SOFTWARE\McNeel\Rhinoceros\7.0\Plug-ins\7CF14AA9-27B0-4585-A42B-493821556924" | Remove-Item -Force -Verbose
