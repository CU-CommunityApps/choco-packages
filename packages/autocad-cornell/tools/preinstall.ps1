mkdir C:\temp -ErrorAction SilentlyContinue

Write-Host "Get current group policy settings"
gpupdate /target:computer /force /wait:-1

Write-Host "Ensuring SYSTEM has symlink privs"
$policyFile="C:\Temp\secpol_current.inf"

# export current group policy settings to file
secedit /export /cfg $policyFile

# read file contents for symlink privs
Select-String -Path $policyFile -Pattern 'secreatesymboliclinkprivilege' -CaseSensitive:$false

# output current token permissions
whoami /all | Out-File -FilePath 'C:\Temp\system-token.txt' -Encoding UTF8 -Force

# Enable symlinks permissions in current SYSTEM token process run
$definition = @"
using System;
using System.Runtime.InteropServices;
public class TokenHelpers
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct LUID
    {
        public uint LowPart;
        public int HighPart;
    }
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct LUID_AND_ATTRIBUTES
    {
        public LUID Luid;
        public uint Attributes;
    }
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TOKEN_PRIVILEGES
    {
        public uint PrivilegeCount;
        public LUID_AND_ATTRIBUTES Privileges;
    }
    public const uint SE_PRIVILEGE_ENABLED = 0x00000002;
    public const int TOKEN_ADJUST_PRIVILEGES = 0x0020;
    public const int TOKEN_QUERY = 0x0008;
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(
        IntPtr ProcessHandle,
        int DesiredAccess,
        out IntPtr TokenHandle
    );
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool LookupPrivilegeValue(
        string lpSystemName,
        string lpName,
        out LUID lpLuid
    );
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool AdjustTokenPrivileges(
        IntPtr TokenHandle,
        bool DisableAllPrivileges,
        ref TOKEN_PRIVILEGES NewState,
        int Zero,
        IntPtr Null1,
        IntPtr Null2
    );
}
"@
Add-Type -TypeDefinition $definition -ErrorAction Stop
# Get current process token
$procHandle = [TokenHelpers]::GetCurrentProcess()
$tokenHandle = [IntPtr]::Zero
if (-not [TokenHelpers]::OpenProcessToken(
    $procHandle,
    [TokenHelpers]::TOKEN_ADJUST_PRIVILEGES -bor [TokenHelpers]::TOKEN_QUERY,
    [ref] $tokenHandle
)) {
    throw "OpenProcessToken failed. Win32 error: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
# Lookup the LUID for SeCreateSymbolicLinkPrivilege
$luid = New-Object TokenHelpers+LUID
if (-not [TokenHelpers]::LookupPrivilegeValue(
    $null,
    "SeCreateSymbolicLinkPrivilege",
    [ref] $luid
)) {
    throw "LookupPrivilegeValue failed. Win32 error: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
# Build TOKEN_PRIVILEGES structure
$tp = New-Object TokenHelpers+TOKEN_PRIVILEGES
$tp.PrivilegeCount = 1
$tp.Privileges = New-Object TokenHelpers+LUID_AND_ATTRIBUTES
$tp.Privileges.Luid = $luid
$tp.Privileges.Attributes = [TokenHelpers]::SE_PRIVILEGE_ENABLED
# Enable the privilege
if (-not [TokenHelpers]::AdjustTokenPrivileges(
    $tokenHandle,
    $false,
    [ref] $tp,
    0,
    [IntPtr]::Zero,
    [IntPtr]::Zero
)) {
    throw "AdjustTokenPrivileges failed. Win32 error: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
Write-Host "SeCreateSymbolicLinkPrivilege enabled in current process."

whoami /all | Out-File -FilePath 'C:\Temp\system-token-updated.txt' -Encoding UTF8 -Force

# Pre install the ID Manager Component Test
# Output everything to STDOUT
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "$env:INSTALL_DIR\image\Installer.exe"
$psi.Arguments = "--manifest `"$env:INSTALL_DIR\AdskIdentityManager-UCT-Installer\setup.xml`" --install_mode install --offline_mode --silent --trigger_point local"
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError  = $true
$psi.UseShellExecute = $false
$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi
$proc.Start() | Out-Null
$proc.WaitForExit()
# Write child stdout/stderr to this PowerShell stdout
$proc.StandardOutput.ReadToEnd()
$proc.StandardError.ReadToEnd()

#Start-Process "$INSTALL_DIR\image\Installer.exe" -ArgumentList "--manifest $INSTALL_DIR\AdskIdentityManager-UCT-Installer\setup.xml --install_mode install --offline_mode --silent --trigger_point local" -Verbose
