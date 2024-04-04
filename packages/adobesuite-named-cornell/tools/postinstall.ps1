# Runs after the choco package is installed

#Installation dir location
$INSTALL_DIR = Join-Path $PSScriptRoot 'installer'

# Fix Updated Browser Warnings
Start-Process -filepath $env:windir\regedit.exe -Argumentlist "/s $INSTALL_DIR\adobe.reg"

# Stop and disable updater services
Stop-Service AdobeUpdateService -Force
Set-Service AdobeUpdateService -StartupType Disabled

#Remove Adobe Notifications
Get-AppxPackage -AllUsers *AdobeNotificationClient* | Remove-AppxPackage -AllUsers

$SourceDir   = "$PSScriptRoot\Fonts\"

foreach ($fontItem in (Get-ChildItem -Path $SourceDir -Include '*.ttf','*.ttc','*.otf' -Recurse))  {  
    
	# Install each font in the Fonts folder in Tools Dir

	# Copy fonts to C:\Windows\Fonts directory
    If (!(Test-Path ("$($env:windir)\Fonts\" + $fontItem.Name))) {  
        write-host "Copying font: $($fontItem.Name)"
        Copy-Item -Path $fontItem.FullName -Destination ("$($env:windir)\Fonts\" + $fontItem.Name) -Force 
    } else {  write-host "Font already exists: $fontItem" }

    # Create corresponding registry entry to register the font
    If (!(Get-ItemProperty -Name $fontItem -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
        write-host "Registering font: $fontItem"
        New-ItemProperty -Name $fontItem -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontItem.Name -Force -ErrorAction SilentlyContinue | Out-Null  
    } else {  write-host "Font already registered: $fontItem" }

}
