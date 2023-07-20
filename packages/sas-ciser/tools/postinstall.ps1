# Runs after the choco package is installed
# Remove temporary installation files
rm "$env:windir\Temp\sasresponse" -Force
rm "$env:windir\Temp\SAS94_9CVRPT_70084773_Win_X64_Srv.txt" -Force
