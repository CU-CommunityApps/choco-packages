# Runs after the choco package is installed
# Remove temporary installation files
rm "$env:windir\Temp\sdwresponse.properties" -Force
rm "$env:windir\Temp\SAS94_9CK519_70084773_Win_X64_Srv.txt" -Force
