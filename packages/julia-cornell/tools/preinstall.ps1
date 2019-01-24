# Runs before the choco package is installed
Start-Process "$env:ALLUSERSPROFILE\chocolatey\choco.exe" -ArgumentList "install julia --confirm --install-arguments=/D=C:\ProgramData\Julia" -NoNewWindow

# Working dir for Julia
MD C:\Work
$Acl = Get-Acl "C:\Work"
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "C:\Work" $Acl
