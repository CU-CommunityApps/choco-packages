Set-Location 'C:\Windows\Temp'

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\choco.exe'   -ArgumentList 'git python'
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\git.exe'     -ArgumentList 'clone https://github.com/CU-CommunityApps/choco-packages.git .\choco-packages'
Start-Process -NoNewWindow -Wait -FilePath 'C:\ProgramData\chocolatey\bin\python.exe'  -ArgumentList '.\choco-packages\bootstrap\go.py'

