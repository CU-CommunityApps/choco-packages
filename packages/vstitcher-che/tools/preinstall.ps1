# Runs before the choco package is installed 

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

Start-Process msiexec.exe -Wait -ArgumentList '/I %INSTALL_DIR%\SSCERuntime_x64-ENU.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList '/I %INSTALL_DIR%\vcredist.x86.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList '/I %INSTALL_DIR%\vcredist.x64.msi /quiet'
# Start-Process -FilePath '%INSTALL_DIR%\haspdinst.exe' -ArgumentList '-install'
Start-Process msiexec.exe -Wait -ArgumentList '/I %INSTALL_DIR%\SSCERuntime_x86-ENU.msi /quiet'
