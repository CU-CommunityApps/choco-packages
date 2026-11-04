# AppStream SessionStart (User context)
# Launch the client in the user's session so KeyServer reports the AppStream user (Last User = AppStream_UserName).
Start-Process "$env:ProgramFiles\Sassafras K2\Client\keyacc32.exe" -ArgumentList "-minimize"

