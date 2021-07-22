Write-Output "Returning license..."
Start-Process "$env:ProgramFiles\Tableau\Tableau 2021.2\bin\tableau.exe" -ArgumentList "-return $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY" -Wait
