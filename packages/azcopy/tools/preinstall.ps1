# Runs before the choco package is installed

$ErrorActionPreference = 'Stop'

# Paths
$zipPath        = 'C:\Windows\Temp\azcopyv10.zip'
$tempExtract   = 'C:\Windows\Temp\azcopyv10'
$installDir    = 'C:\Program Files\AzCopy'
$azCopyExePath = Join-Path $installDir 'azcopy.exe'

# Ensure install directory exists
if (-not (Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
}

# Download latest AzCopy v10 (handles redirect)
$redirect = Invoke-WebRequest `
    -Uri 'https://aka.ms/downloadazcopy-v10-windows' `
    -UseBasicParsing `
    -MaximumRedirection 0 `
    -ErrorAction SilentlyContinue

Invoke-WebRequest `
    -Uri $redirect.Headers.Location `
    -UseBasicParsing `
    -OutFile $zipPath

# Clean previous extraction if present
if (Test-Path $tempExtract) {
    Remove-Item -Path $tempExtract -Recurse -Force
}

# Extract ZIP
Expand-Archive -Path $zipPath -DestinationPath $tempExtract -Force

# Locate azcopy.exe inside versioned folder
$azCopyExe = Get-ChildItem -Path $tempExtract -Recurse -Filter azcopy.exe | Select-Object -First 1

if (-not $azCopyExe) {
    throw 'azcopy.exe not found after extraction'
}

# Copy azcopy.exe to Program Files
Copy-Item -Path $azCopyExe.FullName -Destination $azCopyExePath -Force

# Add install directory to SYSTEM PATH (Option 1)
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')

if ($machinePath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable(
        'Path',
        "$machinePath;$installDir",
        'Machine'
    )
}

# Optional cleanup
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

$sasToken = "?sv=2026-02-06&ss=bfqt&srt=sco&sp=rlp&se=2027-09-01T21:59:13Z&st=2026-08-14T13:44:13Z&spr=https&sig=15%2BzetqgSSG4wR3yCv%2FicxFtUGt2mJNIZoNnKqyymww%3D"
$containerUrl = "https://aodimageresources.blob.core.windows.net/packages/CHE-Kaledo"

& "C:\Program Files\AzCopy\azcopy.exe" copy "$containerUrl$sasToken" "$PSScriptRoot/CHE-Kaledo" --recursive=true