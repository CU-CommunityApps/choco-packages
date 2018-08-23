# CU Choco Package Metadata Repository

## To run bootstrap locally:

    Invoke-Command -ScriptBlock ([scriptblock]::Create(((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/CU-CommunityApps/choco-packages/master/bootstrap/entry.ps1')))) -ArgumentList 'manual'

## Manually troubleshoot applications with the chocolateyinstall script

	PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates>
	
	help .\chocolateyinstall.ps1 -Full
	help .\chocolateyinstall.ps1 -Examples

<#
.SYNOPSIS

    AppStream 2.0 installer script
.DESCRIPTION

    Perform standard or custom Windows tasks on an AppStream 2.0 Image Builder for Fleet automation. Install applications and choco packages, copy files, create environment variables, edit registry, services and scheduled tasks.
.PARAMETER Mode

    The operating mode of this script. There are 2 modes for troubleshooting applications locally during preliminary test. 
    t = TROUBLESHOOTING MODE - Enables local instance troubleshooting for applications
    u = UNINSTALL MODE - Runs choco uninstall
.PARAMETER App

    Application name for TROUBLESHOOTING or UNINSTALL modes.
.PARAMETER S3

    S3 bucket name for installer files. Bucket name only, do not include entire path. i.e. if S3 bucket path is https://s3.amazonaws.com/mybucket input 'mybucket'
.EXAMPLE

    PS C:\Programdata\chocolatey\lib-bad\firefox> 
    .\chocolateyinstall.ps1 -Mode t
.EXAMPLE

    PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates>
    .\chocolateyinstall.ps1 -Mode t -App firefox -S3 mybucket
.EXAMPLE

    PS C:\Windows\Temp\choco-bootstrap\choco-packages\bootstrap\templates> 
    .\chocolateyinstall.ps1 -Mode u -App chrome
.LINK

    https://github.com/CU-CommunityApps/choco-packages
    https://confluence.cornell.edu/display/CLOUD/Cornell+Stream
.NOTES

    TROUBLESHOOTING and UNINSTALL modes can be used locally when performing preliminary application testing
#>

	