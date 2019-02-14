# Runs before the choco package is installed
# Copy pre installation files
cp "$env:TOOLS_DIR\sdwresponse.properties" "$env:windir\temp\sdwresponse.properties" -Force
cp "$env:INSTALL_DIR\sid_files\SAS94_9BYDPR_70084772_Win_X64_Srv.txt" "$env:windir\temp\SAS94_9BYDPR_70084772_Win_X64_Srv.txt" -Force
