# Create User Environment variable
#[Environment]::SetEnvironmentVariable("AoD_Combo", "$env:AppStream_UserName.$env:AppStream_Resource_Name", "User")

# Populate variable with Streaming Instance specific values
$env:AoD_Combo = "$env:AppStream_UserName.$env:AppStream_Resource_Name"
#Write-Output "$env:AoD_Combo"

# Launch Sassafras client
Start-Process "$env:windir\keyacc32.exe" -ArgumentList "-minimize"
