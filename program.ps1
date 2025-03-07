[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

If (!(Get-Module PSWindowsUpdate)){Install-PackageProvider -Name nuget -MinimumVersion 2.8.5.201 -Force;Install-Module -Name PSWindowsUpdate -Force}
Set-AWSCredential -ProfileName appstream_machine_role

New-Variable -Name BUCKET_PREFIX -Value 'image-build' -Option Constant
New-Variable -Name CHOCO_REPO -Value 'https://chocolatey.org/api/v2' -Option Constant
New-Variable -Name USER_DATA_URI -Value 'http://169.254.169.254/latest/user-data' -Option Constant

[string]$SYSTEM_DRIVE = $ENV:SYSTEMDRIVE
[string]$PROGRAM_DATA = $ENV:ALLUSERSPROFILE
[string]$IMAGE_ASSISTANT_EXE = [IO.Path]::Combine("$ENV:ProgramFiles", "Amazon", "Photon", "ConsoleImageBuilder")
[string]$TEMP_DIR = Join-Path $PROGRAM_DATA 'TEMP'
[string]$PACKAGE_PATH = Join-Path $TEMP_DIR 'packages'
[string]$INSTALLED_LOCK = Join-Path $TEMP_DIR 'INSTALLED.lock'
[string]$UPDATED_LOCK = Join-Path $TEMP_DIR 'UPDATED.lock'
[string]$SNAPSHOT_LOCK = Join-Path $TEMP_DIR 'SNAPSHOT.lock'
[string]$REBOOT_LOCK = Join-Path $TEMP_DIR 'REBOOT.lock'

Function DownloadFile($uri, $out_path) {

    # Download file to install
    Start-BitsTransfer -Source $uri -Destination $out_path -Priority Foreground

}

Function CallRestService($uri, $method, $body) {

    $result = irm -Uri $uri -Method $method -Body $body -ContentType "application/json"

    return $result

}

Function RebootSystem() {
    PutCloudWatchLog "Rebooting in 2 min"
    Start-Sleep -s 120
    PutCloudWatchLog "Requesting Image Builder Stop..."

    # Check for Reboot lock
    try {
        if (!(test-path $REBOOT_LOCK)) {
            New-Item -Path $REBOOT_LOCK -Force
            Set-Content -Path $REBOOT_LOCK -Value 'REBOOT'
        }

        # Stop image builder
        Stop-APSImageBuilder -Name $build_id
    }
    catch {

        PutCloudWatchLog "Restart API Exception"
        PutCloudWatchLog "Restarting using shutdown.exe"

        Start-Process 'shutdown.exe' -ArgumentList '/r /f /t 0'
    }

}

Function InitializeEnvironment() {

    $user_data = CallRestService $USER_DATA_URI "GET" $null
    $build_arn = $user_data.resourceArn
    $arn = $build_arn.Split(':')
    $aws_region = $arn[3]
    $aws_account = $arn[4]
    $global:build_id = $arn[5].Split('/')[1]
    $build_bucket = $("$BUCKET_PREFIX-$aws_account-$aws_region")
    $global:build_branch = $build_id.Split('.')[1]
    $build_ids = @()
    $temp_build_id = $build_id.Split('.')

    for ($i = 2; $i -lt $temp_build_id.Length; $i++){
        $build_ids += $temp_build_id[$i]
    }

    $application = $build_id.Split('.')[0]
    $global:image_name = $build_ids -join '.'
    $global:bucket_uri = $("https://$build_bucket.s3.amazonaws.com")
    $statement = "SELECT entry_info FROM `"$application`" WHERE entry_type='ImageBuild' AND entry_id='$image_name'"
    $resp = Invoke-DDBDDBExecuteStatement -Statement $statement
    $global:install_updates = $resp.entry_info.M.InstallUpdates.BOOL
    $global:packages = $resp.entry_info.M.Packages.L | % {$_.S}

    try {
        # Create CloudWatch Log Group
        New-CWLLogGroup -LogGroupName 'image-builds'
    }
    catch {}

    try {
        $log_stream = (Get-CWLLogStream -LogGroupName 'image-builds' -LogStreamNamePrefix $build_id)[0]

        $global:log_stream_token = $log_stream.UploadSequenceToken
    }
    catch {
        # Create CloudWatch Log Stream
        New-CWLLogStream -LogGroupName 'image-builds' -LogStreamName $build_id

        $log_message = @{}
        $message = "Initialized Log Stream"
        $timestamp = Date

        $log_message.add('Message', $message)
        $log_message.add('Timestamp', $timestamp)

        $global:log_stream_token = Write-CWLLogEvent -LogGroupName 'image-builds' -LogStreamName $build_id -LogEvent $log_message

    }

    PutCloudWatchLog "Environment Initialized"

}

Function PutCloudWatchLog($message){

    if ($message.Length -lt 1){
        return
    }

    try {
        
        $log_message = @{}
        $timestamp = Date

        $log_message.add('Message', $message)
        $log_message.add('Timestamp', $timestamp)

        $global:log_stream_token = Write-CWLLogEvent -LogGroupName 'image-builds' -LogStreamName $build_id -LogEvent $log_message -SequenceToken $log_stream_token

    }
    catch {
        Write-Host "Uncaught CloudWatch Exception"
    }

}

Function InstallPackages(){

    ForEach ($package in $packages){
        $package_name = $package.Split(';')[0]
        $package_version = $package.Split(';')[1]
        $package_local = Join-Path $PACKAGE_PATH "$package_name.$package_version.nupkg"
        $package_local_choco =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "lib", $package_name, "$package_name.nupkg")
        $package_uri = "$bucket_uri/packages/$build_branch/$package_name.$package_version.nupkg"
        $package_log =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "lib", $package_name, "$package_name.$package_version.log")
        $choco_path =  [IO.Path]::Combine("$PROGRAM_DATA", "chocolatey", "bin", "choco.exe")

        PutCloudWatchLog "Downloading $package_name.$package_version"
        DownloadFile $package_uri $package_local

        PutCloudWatchLog "Installing $package_name.$package_version"

        $choco_process = New-Object System.Diagnostics.ProcessStartInfo
        $choco_process.FileName = $choco_path
        $choco_process.RedirectStandardError = $true
        $choco_process.RedirectStandardOutput = $true
        $choco_process.UseShellExecute = $false
        $choco_process.Arguments = "install $package_name -y --no-progress --execution-timeout=7200 -r -s $CHOCO_REPO;$PACKAGE_PATH --cachelocation $SYSTEM_DRIVE\TEMP"
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $choco_process
        $process.Start() | Out-Null
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        $exit_code = $process.ExitCode
        PutCloudWatchLog "Exit Code: $exit_code"
        PutCloudWatchLog $stdout
        PutCloudWatchLog "$package_name.$package_version Installed! (Check the log above to be sure)"
        
        Remove-Item -Path $package_local -Force

        If (Test-Path $package_local_choco){
            Remove-Item -Path $package_local_choco -Force
        }
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
        New-Item -Path $UPDATED_LOCK -Force
        Set-Content -Path $UPDATED_LOCK -Value "NO WINDOWS UPDATES"
        return
    }

    PutCloudWatchLog "Installing $($updates.Count) Critical/Security Updates..."
    
    for($i = 0; $i -lt $updates.Count; $i++){
        
        $process = Install-WindowsUpdate -KBArticleID $updates[$i].KBArticleIDs -IgnoreReboot -Verbose -Confirm:$false
            
        if ($process.Result -eq "Failed"){        
            PutCloudWatchLog "Failed: $($updates[$i].Title)"
        }
        else {
            PutCloudWatchLog "Installed: $($updates[$i].Title)"
        }
    }
    
    PutCloudWatchLog "Windows Updates Completed!"

    if (!(test-path $UPDATED_LOCK)) {
        New-Item -Path $UPDATED_LOCK -Force
    }
    Set-Content -Path $UPDATED_LOCK -Value "WINDOWS UPDATES INSTALLED"

}

Function InitiateSnapshot() {
    PutCloudWatchLog "Initiating Snapshot in two minutes..."
    Start-Sleep -s 120

    Set-Location $IMAGE_ASSISTANT_EXE
    $create_cmd = ".\image-assistant.exe create-image --name `"$image_name`" --display-name `"$image_name`" --no-enable-dynamic-app-catalog"
    $create = Invoke-Expression $create_cmd | ConvertFrom-Json
    if ($create.status -eq 0){
        PutCloudWatchLog "Successfully Initiated Snapshot!"
    }
    else {
        PutCloudWatchLog "ERROR creating Image $image_name"
        PutCloudWatchLog "Error Code: $($create.status) :: Error Message: $($create.message)"
        RebootSystem
    }
}

Function Date() {

    return get-date

}

if (!(Test-Path $PACKAGE_PATH)){New-Item -Path $PACKAGE_PATH -ItemType directory}

try {
    InitializeEnvironment

    if (!(Test-Path $REBOOT_LOCK)){
        RebootSystem
    }
    elseif (!(Test-Path $INSTALLED_LOCK)){
        InstallPackages
        RebootSystem
    }
    elseif ($install_updates -and !(Test-Path $UPDATED_LOCK)){
        InstallUpdates
        RebootSystem
    }
    else {
        InitiateSnapshot
    }
}
catch {
    InitializeEnvironment
    PutCloudWatchLog "[FATAL] Uncaught Exception: $($PSItem.Exception.StackTrace) $($PSItem.Exception.Message)"
    RebootSystem
}
