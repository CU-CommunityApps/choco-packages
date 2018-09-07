# Runs after the choco package is installed
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y numpy" -NoNewWindow
