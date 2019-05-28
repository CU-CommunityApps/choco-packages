# Runs after the choco package is installed
# Remove temporary installation files
rm "$env:windir\Temp\sdwresponse.properties" -Force
rm "$env:windir\Temp\SAS94_9BYDPR_70084772_Win_X64_Srv.txt" -Force