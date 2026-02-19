# Runs before the choco package is installed 
mkdir C:\temp
whoami /all | Out-File -FilePath 'C:\Temp\system-token.txt' -Encoding UTF8 -Force
