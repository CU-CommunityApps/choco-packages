# Runs after the choco package is installed
Stop-Service gupdate
Set-Service gupdate -StartupType Disabled
Stop-Service gupdatem
Set-Service gupdatem -StartupType Disabled
