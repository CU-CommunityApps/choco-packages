# AppStream SessionStart (User context)
# Launch the client in the user's session so KeyServer reports the AppStream user (Last User = AppStream_UserName).
# Wait for sessionstart_system.ps1 to finish restarting KeyAccess first; launching during the restart
# leaves Last User = PhotonUser. Capped at 20s so the session start (AppStream waitingTime 30s) isn't blocked.

$marker = "$env:ProgramData\k2client-cornell\service-ready"
$deadline = (Get-Date).AddSeconds(20)
while (-not (Test-Path $marker) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
if (Test-Path $marker) { "Service ready: $(Get-Content $marker)" } else { "Timed out waiting for $marker - launching anyway" }

Start-Sleep -Seconds 2
Start-Process "$env:ProgramFiles\Sassafras K2\Client\keyacc32.exe" -ArgumentList "-minimize"
"keyacc32 launched $(Get-Date -Format o)"
