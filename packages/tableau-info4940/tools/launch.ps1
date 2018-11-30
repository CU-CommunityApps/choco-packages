Do {write-host "Activating Tableau please wait..." -ForegroundColor Yellow;Start-Sleep -Seconds 5}
Until((Get-ScheduledTask -TaskName Tableau_Activation).State -ne "Running")

If ((Get-ScheduledTask -TaskName Tableau_Activation | Get-ScheduledTaskInfo).LastTaskResult -eq 0 -or `
(Get-ScheduledTask -TaskName Tableau_Activation | Get-ScheduledTaskInfo).LastRunTime -eq $null){
Start-Process -FilePath "$env:ProgramFiles\Tableau\Tableau 2018.3\bin\tableau.exe"}