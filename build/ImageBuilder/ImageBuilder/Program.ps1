[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-PackageProvider -Name nuget -MinimumVersion 2.8.5.201 -Force;Install-Module -Name PSWindowsUpdate -Force

New-Variable -Name BUCKET_PREFIX -Value 'image-build' -Option Constant
New-Variable -Name CHOCO_REPO -Value 'https://chocolatey.org/api/v2' -Option Constant
New-Variable -Name USER_DATA_URI -Value 'http://169.254.169.254/latest/user-data' -Option Constant

[string]$SYSTEM_DRIVE = $Env:SYSTEMDRIVE
[string]$PROGRAM_DATA = $Env:ALLUSERSPROFILE
[string]$IMAGE_ASSISTANT_EXE = [IO.Path]::Combine("$PROGRAM_DATA", "Amazon", "Photon", "ConsoleImageBuilder", "image-assistant.exe")
[string]$TEMP_DIR = Join-Path $PROGRAM_DATA 'TEMP'
[string]$PACKAGE_PATH = Join-Path $TEMP_DIR 'packages'
[string]$INSTALLED_LOCK = Join-Path $TEMP_DIR 'INSTALLED.lock'
[string]$UPDATED_LOCK = Join-Path $TEMP_DIR 'UPDATED.lock'
[string]$SNAPSHOT_LOCK = Join-Path $TEMP_DIR 'SNAPSHOT.lock'
[string]$REBOOT_LOCK = Join-Path $TEMP_DIR 'REBOOT.lock'

$log_stream_token;

Function DownloadString($uri) {
    # Logger "Downloading String: $uri"

    # Download api gateway url via text file, created during deployment
    $result = irm -Uri $uri

    return $result

}

Function DownloadFile($uri, $out_path) {
    # Logger "Downloading: $uri to $out_path"

    # Download file to install
    iwr $uri -OutFile $out_path

    # Logger "File downloaded"

}

Function CallRestService($uri, $method, $body) {
    # Logger "Calling Rest Service $uri with body $body"

    $result = irm -Uri $uri -Method $method -Body $body -ContentType "application/json"

    return $result

}

Function RebootSystem() {
    # Logger "Rebooting in 2 min"
    Start-Sleep -s 120
    # Logger "Requesting Image Builder Stop..."

    # Check for Reboot lock
    try {
        if (!(test-path $REBOOT_LOCK)) {
            New-Item -Path $REBOOT_LOCK -Force
            Set-Content -Path $REBOOT_LOCK -Value 'REBOOT'
        }

        # Stop image builder
        Stop-APSImageBuilder -Name $imagebuilder
    }
    catch {
        # Logger "Uncaught exception"
        # Logger "Restarting using shutdown.exe"

        Start-Process 'shutdown.exe' -ArgumentList '/r /f /t 0'
    }

}

Function InitiateEnvironment() {

    $user_data = CallRestService $USER_DATA_URI "GET" $null
    $build_arn = $user_data.resourceArn
    $arn = $build_arn.Split(':')
    $aws_region = $arn[3]
    $aws_account = $arn[4]
    $build_id = $arn[5].Split('/')[1]
    $build_bucket = $("$BUCKET_PREFIX-$aws_account-$aws_region")
    $build_branch = $build_id.Split('.')[1]
    $build_ids = @()
    $temp_build_id = $build_id.Split('.')

    for ($i = 2; $i -lt $temp_build_id.Length; $i++){
        $build_ids += $temp_build_id[$i]
    }

    $global:image_name = $build_ids -join '.'
    $bucket_uri = $("https://$build_bucket.s3.amazonaws.com")
    $api_uri = $(DownloadString "$bucket_uri/api_endpoint.txt") -replace '\s',''
    $build_post = $("{`"BuildId`":`"$image_name`"}")
    $build_info = CallRestService "$api_uri/image-build" 'POST' "$build_post"
    $global:install_updates = $build_info.InstallUpdates
    $packages = $build_info.Packages

    try {
        # Create CloudWatch Log Group
        New-CWLLogGroup -LogGroupName 'image-builds'
    }
    catch {}

    try {
        $log_stream = (Get-CWLLogStream -LogGroupName 'image-builds' -LogStreamNamePrefix $build_id)[0]

        $log_stream_token = $log_stream.UploadSequenceToken
    }
    catch {
        # Create CloudWatch Log Stream
        New-CWLLogStream -LogGroupName 'image-builds' -LogStreamName $build_id

        $log_message.Message = "Initialized Log Stream"
        $log_message.Timestamp = Date

        $resp = Write-CWLLogEvent -LogGroupName 'image-builds' -LogStreamName $build_id -LogEvent $log_message
        
        $log_stream_token = $resp.NextSequenceToken

    }

    PutCloudWatchLog "Environment Initialized"

}

Function PutCloudWatchLog($message){

    if ($message.Length -lt 1){
        return
    }

    try {

        $log_message.Message = $message
        $log_message.Timestamp = Date

        $resp = Write-CWLLogEvent -LogGroupName 'image-builds' -LogStreamName $build_id -LogEvent $log_message
        $resp.SequenceToken = $log_stream_token
        $log_stream_token = $resp.NextSequenceToken

    }
    catch {
        Write-Host "Uncaught CloudWatch Exception"
    }

}

Function InstallPackages(){

    ForEach ($package in $packages){
        $package_name = $package.Split(';')[0]
        $package_version = $package.Split(';')[1]
        $package_local = Join-Path $PACKAGE_PATH, "$package_name.$package_version.nupkg"
        $package_local_choco =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "lib", $package_name, "$package_name.nupkg")
        $package_uri = "$bucket_uri/packages/$build_branch/$package_name.$package_version.nupkg"
        $package_log =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "lib", $package_name, "$package_name.$package_version.log")
        $choco_path =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "bin", "choco.exe")

        PutCloudWatchLog "Downloading $package_name.$package_version"
        DownloadFile $package_uri $package_local

        PutCloudWatchLog "Installing $package_name.$package_version"

        #Start-Process $choco_path -ArgumentList "install {$package_name} -y --no-progress --execution-timeout=7200 -r -s {$CHOCO_REPO};{$PACKAGE_PATH} --cachelocation {$SYSTEM_DRIVE}\\TEMP"

        $choco_process = New-Object System.Diagnostics.ProcessStartInfo
        $choco_process.FileName = $choco_path
        $choco_process.RedirectStandardError = $true
        $choco_process.RedirectStandardOutput = $true
        $choco_process.UseShellExecute = $false
        $choco_process.Arguments = "install $package_name -y --no-progress --execution-timeout=7200 -r -s $CHOCO_REPO;$PACKAGE_PATH --cachelocation $SYSTEM_DRIVE\TEMP"
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $choco_process
        $process.Start() | Out-Null
        $process.WaitForExit()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        Write-Host "stdout: $stdout"
        Write-Host "stderr: $stderr"
        Write-Host "exit code: " + $process.ExitCode
        PutCloudWatchLog $stdout
        PutCloudWatchLog "$package_name.$package_version Installed! (Check the log above to be sure)"
        
        # Remove-Item -Path $package_local -Force

        # If (Test-Path $package_local_choco){
        #     Remove-Item -Path $package_local_choco -Force
        # }
    }

    if (!(test-path $INSTALLED_LOCK)) {
        New-Item -Path $INSTALLED_LOCK -Force
    }
    Set-Content -Path $INSTALLED_LOCK -Value "PACKAGES INSTALLED"

}

Function InstallUpdates(){

    PutCloudWatchLog "Checking for Windows Updates..."

    $updates = Get-WindowsUpdate -Category 'Security Updates', 'Critical Updates'
    
    if ($updates.Count -lt 1){
        PutCloudWatchLog "No Windows Updates to Install"

        Add-Content -Path $UPDATED_LOCK -Value "NO WINDOWS UPDATES"
        return
    }

    PutCloudWatchLog "Installing $updates.Count Critical/Security Updates..."
    
    for($i = 0; $i -lt $updates.Count; $i++){
         Get-WindowsUpdate -install -KBArticleID $updates[$i].KB -IgnoreRebootRequired
         
         if ($? -eq $true){
            PutCloudWatchLog "Installed: $($updates[$i].Title)"
         }
         else {
            PutCloudWatchLog "Failed: $($updates[$i].Title)"
         }
    }
    
    PutCloudWatchLog "Windows Updates Completed!"

    if (!(test-path $UPDATED_LOCK)) {
        New-Item -Path $UPDATEED_LOCK -Force
    }
    Set-Content -Path $UPDATED_LOCK -Value "WINDOWS UPDATES INSTALLED"

}

Function InitiateSnapshot() {
    PutCloudWatchLog "Initiating Snapshot in two minutes..."
    Start-Sleep -s 120

    $create_cmd = "$IMAGE_ASSISTANT_EXE create-image --name " + $image_name
    $create = Invoke-Expression $create_cmd | ConvertFrom-Json
    if ($create.status -eq 0){
        PutCloudWatchLog "Successfully Initiated Snapshot!"
    }
    else {
        PutCloudWatchLog "ERROR create Image $image_name"
        RebootSystem
    }
}

Function Date() {

    $date = get-date
    $date.IsDaylightSavingTime()
    #$date.ToUniversalTime()
    
    # or display in ISO 8601 format:
    #return $date.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss:ms')
    return $date.ToString('yyyy-MM-ddTHH:mm:ss:ms')

}

if (!(Test-Path $PACKAGE_PATH)){New-Item -Path $PACKAGE_PATH -ItemType directory}

<#
try {
    InitiateEnvironment

    if (!(Test-Path $REBOOT_LOCK)){
        RebootSystem
    }
    elseif (!(Test-Path $INSTALLED_LOCK)){
        InstallPackages
        RebootSystem
    }
    elseif (!(Test-Path $install_updates and !(Test-Path $UPDATED_LOCK))){
        InstallUpdates
        RebootSystem
    }
    else{
        InitiateSnapshot
    }
}
catch {
    InitiateSnapshot
    PutCloudWatchLog "[FATAL] Uncaught Exception:\n\n$($PSItem.Exception.StackTrace)\n\n$($PSItem.Exception.Message)"
    RebootSystem
}
#>

InitiateEnvironment