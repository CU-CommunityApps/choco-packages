# Runs after the choco package is installed

start-process "$env:programfiles\miktex\miktex\bin\x64\mpm.exe" -argumentlist "--admin --update" -wait
