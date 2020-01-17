Write-Output "Launching Google Drive File Stream"
$path = (gci "${env:ProgramFiles}\Google\Drive File Stream\35.0.13.0" -Include GoogleDriveFS.exe -Recurse -ErrorAction SilentlyContinue).DirectoryName
Start-Process "$path\GoogleDriveFS.exe"
