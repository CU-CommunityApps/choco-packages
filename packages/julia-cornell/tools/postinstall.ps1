# Runs after the choco package is installed
$resourceArn = (invoke-restmethod http://169.254.169.254/latest/user-data).resourceArn
$branch = $resourceArn.split(":")[5].split("/")[1].split(".")[1]
$account = $resourceArn.split(":")[4]
$region = $resourceArn.split(":")[3]
$extractFile = "julia-cornell-postfiles.zip"
$downloadOutput = "$env:ALLUSERSPROFILE\TEMP\packages\$extractFile"
$extractOutput = "$env:SystemDrive\Work"

# Download post install zip file
While (!(test-path $downloadOutput)){
    try{
        $URI = "https://image-build-$account-$region.s3.amazonaws.com/installers/$branch/$extractFile"
        Invoke-WebRequest -Uri $uri -OutFile $downloadOutput
    }
    catch{Write-Host "Error downloading, try again..."}
}

# Extract post install zip file
If (test-path $extractOutput){
    Invoke-Expression "7z x `"$downloadOutput`" -y -o`"$extractOutput`""
    Write-Output "Files extracted to $extractOutput"
}
Else {Write-Output "$extractOutput does not exist"}

# Post extraction file copy
If (!(test-path "$env:SystemDrive\Users\Default\.julia\config\startup.jl")){mkdir "$env:SystemDrive\Users\Default\.julia\config" -Force}
cp "$extractOutput\startup.jl" "$env:SystemDrive\Users\Default\.julia\config\startup.jl" -Force
