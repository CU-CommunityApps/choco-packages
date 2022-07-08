# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

<#
.SYNOPSIS
    This script performs the installation or uninstallation of Autodesk 3ds Max 2023.
    # LICENSE #
    PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
    Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
    The script is provided as a template to perform an install or uninstall of an application(s).
    The script either performs an "Install" deployment type or an "Uninstall" deployment type.
    The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
    The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
    The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
    Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
    Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
    Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
    Disables logging to file for the script. Default is: $false.
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Install" -DeployMode "NonInteractive"
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Install" -DeployMode "Silent"
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Install" -DeployMode "Interactive"
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Uninstall" -DeployMode "NonInteractive"
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Uninstall" -DeployMode "Silent"
.EXAMPLE
    PowerShell.exe .\Deploy-Autodesk_3ds_Max_2023.ps1 -DeploymentType "Uninstall" -DeployMode "Interactive"
.NOTES
    Toolkit Exit Code Ranges:
    60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
    69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
    70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
    http://psappdeploytoolkit.com
#>
# Runs before the choco package is installed

# Installation dir location
$INSTALL_DIR =  Join-Path $PSScriptRoot 'installer'

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('Install','Uninstall','Repair')]
    [string]$DeploymentType = 'Install',
    [Parameter(Mandatory=$false)]
    [ValidateSet('Interactive','Silent','NonInteractive')]
    [string]$DeployMode = 'Interactive',
    [Parameter(Mandatory=$false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory=$false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory=$false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [string]$appVendor = 'Autodesk'
    [string]$appName = '3ds Max'
    [string]$appVersion = '2023'
    [string]$appArch = ''
    [string]$appLang = ''
    [string]$appRevision = ''
    [string]$appScriptVersion = '1.0.0'
    [string]$appScriptDate = 'XX/XX/20XX'
    [string]$appScriptAuthor = 'Jason Bergner'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [string]$installName = ''
    [string]$installTitle = 'Autodesk 3ds Max 2023'

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [int32]$mainExitCode = 0

    ## Variables: Script
    [string]$deployAppScriptFriendlyName = 'Deploy Application'
    [version]$deployAppScriptVersion = [version]'3.8.4'
    [string]$deployAppScriptDate = '26/01/2021'
    [hashtable]$deployAppScriptParameters = $psBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
    [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
        If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
    }
    Catch {
        If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, Close 3ds Max With a 60 Second Countdown Before Automatically Closing
        Show-InstallationWelcome -CloseApps '3dsmax,adSSO,AutodeskDesktopApp,AdAppMgrSvc,ADPClientService,AdskLicensingService,AdskLicensingAgent,FNPLicensingService' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress
   
        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Installation'

        If ($ENV:PROCESSOR_ARCHITECTURE -eq 'x86'){
        Write-Log -Message "Detected 32-bit OS Architecture. Autodesk 3ds Max 2023 is not supported on 32-bit operating systems." -Severity 1 -Source $deployAppScriptFriendlyName
      
        }
        Else
        {
        Write-Log -Message "Detected 64-bit OS Architecture" -Severity 1 -Source $deployAppScriptFriendlyName

        ## Install Autodesk 3ds Max 2023
        Show-InstallationProgress "Installing Autodesk 3ds Max 2023. This may take some time. Please wait..."
        Execute-Process -Path "$INSTALL_DIR\Autodesk_3ds_Max_2023\Files\Setup.exe" -Parameters "-q" -WindowStyle Hidden
        }

        ## Remove Autodesk Desktop App Desktop Shortcut (If Present)
        If (Test-Path -Path "$envPublic\Desktop\Autodesk Desktop App.lnk") {
        Write-Log -Message "Removing Autodesk Desktop App Desktop Shortcut."
        Remove-Item -Path "$envPublic\Desktop\Autodesk Desktop App.lnk" -Force -Recurse -ErrorAction SilentlyContinue 
        }

        ## Remove 3ds Max 2023 Desktop Shortcut (If Present)
        If (Test-Path -Path "$envPublic\Desktop\3ds Max 2023.lnk") {
        Write-Log -Message "Removing 3ds Max 2023 Desktop Shortcut."
        Remove-Item -Path "$envPublic\Desktop\3ds Max 2023.lnk" -Force -Recurse -ErrorAction SilentlyContinue 
        }

        ## Disable Data Collection and Use (Autodesk Analytics)
        Write-Log -Message "Disabling Data Collection and Use (Autodesk Analytics)."

        [scriptblock]$HKCURegistrySettings = {
        Set-RegistryKey -Key 'HKCU\Software\Autodesk\MC3' -Name 'ADAOptIn' -Value 0 -Type DWord -SID $UserProfile.SID
        Set-RegistryKey -Key 'HKCU\Software\Autodesk\MC3' -Name 'ADARePrompted' -Value 1 -Type DWord -SID $UserProfile.SID
        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings -ErrorAction SilentlyContinue

       
        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Installation'

    }
    ElseIf ($deploymentType -ieq 'Uninstall')
    {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Uninstallation'

        ## Disable Autodesk Licensing Service
        Set-Service -Name 'AdskLicensingService' -StartupType 'Disabled' -ErrorAction SilentlyContinue

        ## Disable FlexNet Licensing Service
        Set-Service -Name 'FlexNet Licensing Service' -StartupType 'Disabled' -ErrorAction SilentlyContinue

        ## Show Welcome Message, Close 3ds Max With a 60 Second Countdown Before Automatically Closing
        Show-InstallationWelcome -CloseApps '3dsmax,adSSO,AutodeskDesktopApp,AdAppMgrSvc,ADPClientService,AdskLicensingService,AdskLicensingAgent,FNPLicensingService' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress


        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Uninstallation'

        ## Uninstall Autodesk Material Library 2023
        Execute-MSI -Action Uninstall -Path '{A9221A68-5AD0-4215-B54F-CB5DBA4FB27C}'

        ## Uninstall Autodesk Material Library Base Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{6256584F-B04B-41D4-8A59-44E70940C473}'

        ## Uninstall Autodesk Material Library Low Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{490259AE-1021-4BED-B74B-162151EC45C7}'

        ## Uninstall Autodesk Material Library Medium Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{8300AA3F-6ADF-4233-A1FB-73B1894102F0}'

        ## Uninstall Autodesk Advanced Material Library Base Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{7E78B513-B354-4833-8897-3ED5C515D30F}'

        ## Uninstall Autodesk Advanced Material Library Low Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{EEAD8CC3-B6B7-4D4B-AF0D-4BBD3D93D67C}'

        ## Uninstall Autodesk Advanced Material Library Medium Resolution Image Library 2023
        Execute-MSI -Action Uninstall -Path '{493ACC3C-3ABF-4CBB-8F6E-E4433090A589}'

        ## Uninstall Autodesk Licensing
        Show-InstallationProgress "Uninstalling Autodesk Licensing. This may take some time. Please wait..."
        If (Test-Path -Path "$envProgramFilesX86\Common Files\Autodesk Shared\AdskLicensing\uninstall.exe") {
        Execute-Process -Path "$envProgramFilesX86\Common Files\Autodesk Shared\AdskLicensing\uninstall.exe" -Parameters "--mode unattended" -WindowStyle Hidden
        Sleep -Seconds 5
        }

        ## Uninstall Autodesk Save to Web and Mobile
        Execute-MSI -Action Uninstall -Path '{192B349F-C3F7-4BBE-B49E-00DD4BD28373}'

        ## Uninstall Autodesk 3ds Max 2023
        $XML = Get-ChildItem -Path "C:\ProgramData\Autodesk\ODIS\metadata\{B2EF7E27-4824-3656-A115-BFF401F11F7C}\" -Include bundleManifest.xml -File -Recurse -ErrorAction SilentlyContinue
        If($XML.Exists)
        {
        Write-Log -Message "Found $($XML.FullName), now attempting to uninstall Autodesk 3ds Max 2023."
        Show-InstallationProgress "Uninstalling Autodesk 3ds Max 2023. This may take some time. Please wait..."
        If (Test-Path -Path "$envProgramFiles\Autodesk\AdODIS\V1\Installer.exe") {
        Execute-Process -Path "$envProgramFiles\Autodesk\AdODIS\V1\Installer.exe" -Parameters "-i uninstall -q -m C:\ProgramData\Autodesk\ODIS\metadata\{B2EF7E27-4824-3656-A115-BFF401F11F7C}\bundleManifest.xml" -WindowStyle Hidden -IgnoreExitCodes "1603,1605"
        Sleep -Seconds 5
        }
        }

        ## Uninstall Microsoft SQL Server 2014 Express LocalDB 
        Execute-MSI -Action Uninstall -Path '{BAF67399-85CD-4555-9B49-1F80EB921C35}'

        ## Uninstall Substance in 3ds Max 2023
        Execute-MSI -Action Uninstall -Path '{EAFD9CC5-E23B-44B8-8E45-4DC676B83542}'

        ## Uninstall Autodesk Desktop App
        Show-InstallationProgress "Uninstalling Autodesk Desktop App. This may take some time. Please wait..."
        If (Test-Path -Path "$envProgramFilesX86\Autodesk\Autodesk Desktop App\removeAdAppMgr.exe") {
        Execute-Process -Path "$envProgramFilesX86\Autodesk\Autodesk Desktop App\removeAdAppMgr.exe" -Parameters "--mode unattended" -WindowStyle Hidden
        Sleep -Seconds 5
        }

        ## Uninstall Autodesk Single Sign On Component
        Execute-MSI -Action Uninstall -Path '{B9F5BDED-021C-4926-8518-4FA7114B7040}'

        ## Uninstall Autodesk Revit Unit Schemas 2023
        Execute-MSI -Action Uninstall -Path '{CDCC6F31-2023-4900-8E9B-D562B70697B6}'
        $AppList = Get-InstalledApplication -Name 'Autodesk Revit Unit Schemas 2023'        
        ForEach ($App in $AppList)
        {
        If($App.UninstallString)
        {
        Write-log -Message "Found $($App.DisplayName) ($($App.DisplayVersion)) and a valid uninstall string, now attempting to uninstall."
        Execute-ProcessAsUser -Path "$exeMsiexec" -Parameters "/x {CDCC6F31-2023-4900-8E9B-D562B70697B6} REBOOT=ReallySuppress /qn /L*v C:\Windows\Logs\Software\AutodeskRevitUnitSchemas2023.log" -Wait
        }
        }

        ## Cleanup Autodesk Directories
        $Users = Get-ChildItem C:\Users
        foreach ($user in $Users){

        $AutodeskDir1 = "$($user.fullname)\AppData\Local\Autodesk"
        If (Test-Path $AutodeskDir1) {
        Write-Log -Message "Cleanup $AutodeskDir1 Directory."
        Remove-Item -Path $AutodeskDir1 -Force -Recurse -ErrorAction SilentlyContinue
        Sleep -Seconds 5
        }

        $AutodeskDir2 = "$($user.fullname)\AppData\Roaming\Autodesk"
        If (Test-Path $AutodeskDir2) {
        Write-Log -Message "Cleanup $AutodeskDir2 Directory."
        Remove-Item -Path $AutodeskDir2 -Force -Recurse -ErrorAction SilentlyContinue
        Sleep -Seconds 5
        }
        }

        If (Test-Path -Path "$envAllUsersProfile\Autodesk\") {
        Write-Log -Message "Cleanup $envAllUsersProfile\Autodesk\ Directory."
        Remove-Item -Path "$envAllUsersProfile\Autodesk\" -Force -Recurse -ErrorAction SilentlyContinue 
        Sleep -Seconds 5
        }

        ## Uninstall Autodesk Genuine Service
        Stop-Process -Name GenuineService -Force -ErrorAction SilentlyContinue
        Execute-MSI -Action Uninstall -Path '{8AD048E5-9570-442E-A5A2-B12C2618977E}'
        Stop-Process -Name message_router -Force -ErrorAction SilentlyContinue


        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Uninstallation'


    }
    ElseIf ($deploymentType -ieq 'Repair')
    {
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        [string]$installPhase = 'Pre-Repair'


        ##*===============================================
        ##* REPAIR
        ##*===============================================
        [string]$installPhase = 'Repair'


        ##*===============================================
        ##* POST-REPAIR
        ##*===============================================
        [string]$installPhase = 'Post-Repair'


    }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [int32]$mainExitCode = 60001
    [string]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
