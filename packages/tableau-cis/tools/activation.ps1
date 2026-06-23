# Activate product
Write-Output "Activating..."
Start-Process "$env:ProgramFiles\Tableau\Tableau 2026.2\bin\tableau.exe" -ArgumentList "-activate $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY" -Wait
