If (((gwmi win32_computersystem).username -match "CORNELL") -or ((gwmi win32_computersystem).username -match "PhotonUser")){
    write-output "Activating..."
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-activate $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY"
    write-output "Registering..."
    Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-register"
}
