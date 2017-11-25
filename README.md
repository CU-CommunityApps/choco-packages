# CU Choco Package Metadata Repository

To run bootstrap:

    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/master/bootstrap/bootstrap.ps1'))

To run old bootstrap:

    Invoke-Command -ScriptBlock ([scriptblock]::Create(((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/master/bootstrap.ps1')))) -ArgumentList "msoffice-cornell vlc"
