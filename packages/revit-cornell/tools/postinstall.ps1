# Runs after the choco package is installed
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $AdminKey -Name "pac" -Value '"C:\Program Files\Autodesk\Personal Accelerator for Revit\RevitAccelerator.exe"'