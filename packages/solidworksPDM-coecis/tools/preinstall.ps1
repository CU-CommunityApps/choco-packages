# Runs before the choco package is installed
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

# Install ODBC SQL client
Start-Process msiexec.exe -ArgumentList "/i $INSTALL_DIR\msodbcsql.msi /qn IACCEPTMSODBCSQLLICENSETERMS=YES" -Wait  

# Install MS Edge Webview 2 offline installer
Start-Process -FilePath "$INSTALL_DIR\MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -ArgumentList "/silent /install" -Wait