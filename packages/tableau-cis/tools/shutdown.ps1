Write-Output "Returning license..."
Start-Process "$env:ProgramFiles\Tableau\Tableau 2024.1\bin\tableau.exe" -ArgumentList "-return $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY" -Wait
