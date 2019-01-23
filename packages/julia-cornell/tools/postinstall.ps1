# Runs after the choco package is installed
MD C:\Work
$Acl = Get-Acl "C:\Work"

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$Acl.SetAccessRule($Ar)
Set-Acl "C:\Work" $Acl

push!(LOAD_PATH, "C:\\Work")
empty!(DEPOT_PATH)
push!(DEPOT_PATH, "C:\\Work")
