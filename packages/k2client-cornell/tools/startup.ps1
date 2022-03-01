# Populate variable with Streaming Instance specific values
$env:AppStream_Combo = "$env:AppStream_UserName.$env:AppStream_Resource_Name"

# Launch Sassafras client
Start-Process "$env:windir\keyacc32.exe" -ArgumentList "-minimize"
