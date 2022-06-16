# Runs before the choco package is installed
# Copy pre installation files
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

cp "$PSScriptRoot\sasresponse" "$env:windir\temp\sasresponse" -Force
cp "$INSTALL_DIR\sid_files\SAS94_9CQ1HY_70084773_Win_X64_Srv.txt" "$env:windir\temp\SAS94_9CQ1HY_70084773_Win_X64_Srv.txt" -Force

$DEPOT_HOME="$INSTALL_DIR\products"

::Microsoft Office Access Database Engine 2010 (OPTIONAL)

"$DEPOT_HOME\ace__99160__prt__xx__sp0__1\w32\native\AccessDatabaseEngine.exe" /quiet /norestart
"$DEPOT_HOME\ace__99160__prt__xx__sp0__1\wx6\native\AccessDatabaseEngine_X64.exe" /quiet /norestart

::Microsoft Runtime Components 2019 (REQUIRED)

"$DEPOT_HOME\vcredist2019__99110__prt__xx__sp0__1\w32\native\VC_redist.x86.exe" /q /norestart
"$DEPOT_HOME\vcredist2019__99110__prt__xx__sp0__1\wx6\native\VC_redist.x64.exe" /q /norestart
