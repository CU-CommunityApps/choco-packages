# Runs before the choco package is installed

# Working dir for Julia
$dir = "$env:SystemDrive\Work"

# Install Julia.exe in specified location
Start-Process "$env:ALLUSERSPROFILE\chocolatey\choco.exe" -ArgumentList "install julia --no-progress --confirm --install-arguments=/D=C:\ProgramData\Julia" -NoNewWindow

# Julia working dir permission adjustments
MD $dir -Force
$Acl = Get-Acl $dir
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $dir $Acl
