If ($env:AppStream_UserName -match "cornell.edu"){
    
    write-host "Activating Tableau please wait..." -ForegroundColor Yellow
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-activate $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY" -Wait
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-register" -Wait
    write-host "Launching Tableau" -ForegroundColor Green
    Start-Process -FilePath "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe"

}
Else {Start-Process -FilePath "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe"}
