# Runs before the choco package is installed

# The KeyAccess installer extracts its MSI to the temp dir. Choco's runner can leave TEMP/TMP unset or invalid,
# which makes the MSI land in systemprofile and the install silently no-op.
foreach ($v in 'TEMP','TMP') {
    $cur = [Environment]::GetEnvironmentVariable($v, 'Process')
    if (-not $cur -or -not (Test-Path $cur)) { [Environment]::SetEnvironmentVariable($v, "$env:windir\Temp", 'Process') }
}
