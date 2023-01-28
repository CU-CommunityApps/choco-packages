$SourceDir   = "$env:ALLUSERSPROFILE\chocolatey\lib\adobesuite-named-cornell\tools\Fonts\"

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
