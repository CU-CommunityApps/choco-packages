$procLoc = "$env:SystemDrive\Procmon"
$proc = "$env:SystemDrive\Procmon\procmon.exe"

Start-Process $proc -ArgumentList "/accepteula /loadconfig $procLoc\ProcmonConfiguration.pmc /profiling /quiet /minimized /backingfile $procLoc\back.pml"

Start-Sleep -Seconds 30

Start-Process $proc -ArgumentList "/terminate"

Start-Sleep -Seconds 10

Start-Process $proc -ArgumentList "/openlog $procLoc\back.pml /saveas $procLoc\back.csv"

Start-Sleep -Seconds 10

$csv = import-csv "$procLoc\back.csv" | where {$_.Path -like "*.exe" -or $_.Path -like "*.dll"} | sort Path -Unique

$csv | ConvertTo-Csv | select -Skip 2 | Out-File "C:\Procmon\PrewarmManifest.csv"

gc "C:\Procmon\PrewarmManifest.csv" | % {$_ -replace '"'} > "C:\Procmon\PrewarmManifest.txt"