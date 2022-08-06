Write-Output "Returning license..."
Start-Process "$env:ProgramFiles\Tableau\Tableau 2022.2\bin\tableau.exe" -ArgumentList "-return $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY" -Wait
