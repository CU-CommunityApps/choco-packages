# AppStream SessionStart (System context) - set KeyAccess Department to the fleet name
# The KeyAccess service (LocalSystem) starts at boot, before AppStream sets AppStream_Resource_Name,
# so the literal %AppStream_Resource_Name% stored in options\site resolves to nothing -> blank Department.
# Write the real fleet name and restart the service. Username is handled by the User startup.ps1; not touched here.

if ($env:AppStream_Resource_Type -eq 'image-builder') { "Image builder - skipping"; exit 0 }

$opts = 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyAccess\Settings\options'

$site = $null
for ($i = 0; $i -lt 10 -and -not $site; $i++) {
    $site = $env:AppStream_Resource_Name
    if (-not $site) { $site = [Environment]::GetEnvironmentVariable('AppStream_Resource_Name', 'Machine') }
    if (-not $site) { Start-Sleep -Seconds 2 }
}
"AppStream_Resource_Name = '$site'"
if (-not $site) { "No fleet name found - leaving KeyAccess unchanged"; exit 0 }

New-ItemProperty -Path $opts -Name 'site' -Value $site -PropertyType String -Force | Out-Null
Restart-Service -Name KeyAccess -Force
Start-Sleep -Seconds 3
"options\site = " + (Get-ItemProperty $opts).site
"KeyAccess    = " + (Get-Service KeyAccess).Status