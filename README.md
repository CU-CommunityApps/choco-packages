# CU Choco Package Metadata Repository

To run bootstrap locally:

    Invoke-Command -ScriptBlock ([scriptblock]::Create(((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/master/bootstrap/entry.ps1')))) -ArgumentList 'manual'

