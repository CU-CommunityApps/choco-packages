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
if (-not $site) {
    "No fleet name found - leaving KeyAccess unchanged"
    New-Item -ItemType Directory -Path "$env:ProgramData\k2client-cornell" -Force | Out-Null
    Set-Content -Path "$env:ProgramData\k2client-cornell\service-ready" -Value 'skipped'
    exit 0
}

New-ItemProperty -Path $opts -Name 'site' -Value $site -PropertyType String -Force | Out-Null

# Last User: the client expands options\name (set to %AppStream_UserName%) from the MACHINE environment when the
# service starts. AppStream_UserName is user-level, so publish it at machine level before restarting.
# Builder test 2026-11-12: options\name='%AppStream_UserName%' + machine var showed exactly the username
# (a literal in options\name did NOT show; a literal logon\user did). We want the user only, no .resource suffix.
New-ItemProperty -Path $opts -Name 'name' -Value '%AppStream_UserName%' -PropertyType String -Force | Out-Null
$user = $env:AppStream_UserName
for ($i = 0; $i -lt 15 -and -not $user; $i++) {
    foreach ($h in Get-ChildItem Registry::HKEY_USERS -ErrorAction SilentlyContinue) {
        if ($h.PSChildName -match '_Classes$|^\.DEFAULT$|^S-1-5-18$|^S-1-5-19$|^S-1-5-20$') { continue }
        $v = (Get-ItemProperty "Registry::$($h.Name)\Environment" -ErrorAction SilentlyContinue).AppStream_UserName
        if ($v) { $user = $v; break }
    }
    if (-not $user) { Start-Sleep -Seconds 2 }
}
"AppStream_UserName = '$user'"
if ($user) { [Environment]::SetEnvironmentVariable('AppStream_UserName', $user, 'Machine') }
else       { "No AppStream_UserName found - Last User will fall back to the Windows user" }

# Restart-Service fails when KeyAccess reports NOT_STOPPABLE; kill the service process and start it again.
$svcPid = (Get-CimInstance Win32_Service -Filter "Name='KeyAccess'").ProcessId
if ($svcPid) { Stop-Process -Id $svcPid -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 3 }
Start-Service -Name KeyAccess
Start-Sleep -Seconds 3
"options\site = " + (Get-ItemProperty $opts).site
"KeyAccess    = " + (Get-Service KeyAccess).Status

# Signal the User script (startup.ps1) that the restart is done, so its keyacc32 attaches to the new service
$ready = "$env:ProgramData\k2client-cornell"
New-Item -ItemType Directory -Path $ready -Force | Out-Null
Set-Content -Path "$ready\service-ready" -Value (Get-Date -Format o)
"Ready marker written: $ready\service-ready"
