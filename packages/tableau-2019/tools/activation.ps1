If (((gwmi win32_computersystem).username -match "CORNELL") -or ((gwmi win32_computersystem).username -match "PhotonUser")){
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\atrdiag.exe" -ArgumentList "-enableATRFeature"
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\atrdiag.exe" -ArgumentList "-setDuration 57600"
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-activate $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY";Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-register";& 'C:\Program Files\Tableau\Tableau 2019.2\bin\tableau.exe'
}
