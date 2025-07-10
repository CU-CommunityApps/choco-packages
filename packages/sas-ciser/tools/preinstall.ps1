# Runs before the choco package is installed
# Copy pre installation files
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

cp "$PSScriptRoot\sdwresponse.properties" "$env:windir\temp\sdwresponse.properties" -Force
cp "$INSTALL_DIR\sid_files\SAS94_9D27XV_70084773_Win_X64_Srv.txt" "$env:windir\temp\SAS94_9D27XV_70084773_Win_X64_Srv.txt" -Force
<#
:: --------------------------------------------------------------------------------
:: This is a batch system requirements file created from order 9CVRPT at
:: 2022-06-14-15.36.01. The host was 128.84.193.98 and was running on a
:: Windows Server 2019 64-bit machine.
::
:: The following products were used to create this batch file:
::
:: SAS Deployment Tester - Client
:: SAS Enterprise Guide
:: SAS Enterprise Miner Workstation Configuration
:: SAS Foundation
::	• BASE Infrastructure to support Hadoop
::	• Base SAS
::	• GfK GeoMarketing CITIES Maps for SAS/GRAPH
::	• GfK GeoMarketing WORLD Maps for SAS/GRAPH
::	• SAS Accelerator Publishing Agent for Aster
::	• SAS Accelerator Publishing Agent for DB2
::	• SAS Accelerator Publishing Agent for Greenplum
::	• SAS Accelerator Publishing Agent for Hadoop
::	• SAS Accelerator Publishing Agent for Netezza
::	• SAS Accelerator Publishing Agent for Oracle
::	• SAS Accelerator Publishing Agent for SAP HANA
::	• SAS Accelerator Publishing Agent for Teradata
::	• SAS Clinical Standards Toolkit Framework
::	• SAS Data Quality Secure
::	• SAS Data Quality Server
::	• SAS Enterprise Miner
::	• SAS High-Performance Data Mining Server Components
::	• SAS High-Performance Econometrics Server Components
::	• SAS High-Performance Server
::	• SAS High-Performance Statistics Server Components
::	• SAS High-Performance Text Mining Server Components
::	• SAS Integration Technologies
::	• SAS Interface to Viya Model Publishing and Scoring
::	• SAS LASR Analytic Server Access Tools
::	• SAS Network Algorithms
::	• SAS Scalable Performance Data Client
::	• SAS Text Analytics Common Components
::	• SAS Text Analytics for Spanish
::	• SAS Text Miner
::	• SAS/ACCESS Interface to Amazon Redshift
::	• SAS/ACCESS Interface to Aster
::	• SAS/ACCESS Interface to DB2
::	• SAS/ACCESS Interface to Greenplum
::	• SAS/ACCESS Interface to HAWQ
::	• SAS/ACCESS Interface to Hadoop
::	• SAS/ACCESS Interface to Impala
::	• SAS/ACCESS Interface to JDBC
::	• SAS/ACCESS Interface to Microsoft SQL Server
::	• SAS/ACCESS Interface to MySQL
::	• SAS/ACCESS Interface to Netezza
::	• SAS/ACCESS Interface to ODBC
::	• SAS/ACCESS Interface to OLE DB
::	• SAS/ACCESS Interface to Oracle
::	• SAS/ACCESS Interface to PC Files
::	• SAS/ACCESS Interface to PostgreSQL
::	• SAS/ACCESS Interface to R/3
::	• SAS/ACCESS Interface to SAP ASE
::	• SAS/ACCESS Interface to SAP HANA
::	• SAS/ACCESS Interface to SAP IQ
::	• SAS/ACCESS Interface to Salesforce
::	• SAS/ACCESS Interface to Snowflake
::	• SAS/ACCESS Interface to Teradata
::	• SAS/ACCESS Interface to Vertica
::	• SAS/ACCESS Interface to the PI System
::	• SAS/AF
::	• SAS/ASSIST
::	• SAS/CONNECT
::	• SAS/EIS
::	• SAS/ETS
::	• SAS/FSP
::	• SAS/GIS
::	• SAS/GRAPH
::	• SAS/GRAPH Obsolete Maps Data
::	• SAS/Genetics
::	• SAS/IML
::	• SAS/IntrNet
::	• SAS/OR
::	• SAS/QC
::	• SAS/SHARE
::	• SAS/STAT
:: SAS Integration Technologies Client
:: SAS ODS Graphics Designer
:: SAS Providers for OLE DB
:: SAS Studio - Single User
:: SAS Text Miner Workstation Configuration
:: SAS/GRAPH ActiveX Control
::
:: 1. Any entry listed as "(REQUIRED)" MUST be run to ensure the selected
::    products will install properly. For batch files created on 64-bit Windows,
::    there may be required entries that also reference 32-bit operating systems.
:: 2. Any entry listed as "(OPTIONAL)" is not needed for the selected products
::    but are required by other products in 9CGCYK. Optional entries may be
::    removed without affecting the installation of the selected products, but this
::    is NOT recommended.
:: 3. This batch file is only designed to run on machine(s) matching the operating
::    system on which it was created. To run the batch file on other machines, the
::    path to the executables below must be correct. To ensure the accuracy of this
::    batch file, the target depot should be in a location matching the paths in
::    this batch file rather than altering the paths in this batch file. If you must
::    use a different location, SAS recommends changing the SET variable rather than
::    the command for each requirement listed below. 
::
#>
$DEPOT_HOME="$INSTALL_DIR\products"
<#
::
:: --------------------------------------------------------------------------------
:: Microsoft .NET Framework 4.8 (REQUIRED)
::"%DEPOT_HOME%\dotnet48__99110__prt__xx__sp0__1\w32\native\ndp48-x86-x64-allos-enu.exe" /q /lang:ENU /norestart
:: --------------------------------------------------------------------------------
:: Microsoft Office Access Database Engine 2010 (OPTIONAL)
"%DEPOT_HOME%\ace__99160__prt__xx__sp0__1\w32\native\AccessDatabaseEngine.exe" /quiet /norestart
"%DEPOT_HOME%\ace__99160__prt__xx__sp0__1\wx6\native\AccessDatabaseEngine_X64.exe" /quiet /norestart
:: --------------------------------------------------------------------------------
:: Microsoft Runtime Components 2019 (REQUIRED)
#>
Start-Process "$DEPOT_HOME\vcredist2019__99110__prt__xx__sp0__1\w32\native\VC_redist.x86.exe" -ArgumentList "/q /norestart"
Start-Process "$DEPOT_HOME\vcredist2019__99110__prt__xx__sp0__1\wx6\native\VC_redist.x64.exe" -ArgumentList "/q /norestart"
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\FileRenameOperations" -Recurse -Force -ErrorAction SilentlyContinue
