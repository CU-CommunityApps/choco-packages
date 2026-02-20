mkdir C:\temp -ErrorAction SilentlyContinue

Write-Host "Get current group policy settings"
gpupdate /target:computer /force /wait:-1

Write-Host "Ensuring SYSTEM has symlink privs"
$policyFile="C:\Temp\secpol_current.inf"

# export current group policy settings to file
secedit /export /cfg $policyFile

# read file contents for symlink privs
Select-String -Path $policyFile -Pattern 'secreatesymboliclinkprivilege' -CaseSensitive:$false

$definition = @"
using System;
using System.Runtime.InteropServices;
public class TokenHelpers
{
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID
    {
        public uint LowPart;
        public int HighPart;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID_AND_ATTRIBUTES
    {
        public LUID Luid;
        public uint Attributes;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct TOKEN_PRIVILEGES
    {
        public uint PrivilegeCount;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 64)]
        public LUID_AND_ATTRIBUTES[] Privileges;
    }
    public const uint SE_PRIVILEGE_ENABLED = 0x00000002;
    public const uint SE_PRIVILEGE_DISABLED = 0x00000000;
    public const int TOKEN_QUERY = 0x0008;
    public const int TOKEN_ADJUST_PRIVILEGES = 0x0020;
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
    public static extern bool GetTokenInformation(
        IntPtr TokenHandle,
        int TokenInformationClass,
        IntPtr TokenInformation,
        int TokenInformationLength,
        out int ReturnLength
    );
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool AdjustTokenPrivileges(
        IntPtr TokenHandle,
        bool DisableAllPrivileges,
        ref TOKEN_PRIVILEGES NewState,
        int BufferLength,
        IntPtr PreviousState,
        IntPtr ReturnLength
    );
}
"@
Add-Type -TypeDefinition $definition -ErrorAction Stop
# Open current process token
$procHandle = [TokenHelpers]::GetCurrentProcess()
$tokenHandle = [IntPtr]::Zero
$access = [TokenHelpers]::TOKEN_QUERY -bor [TokenHelpers]::TOKEN_ADJUST_PRIVILEGES
if (-not [TokenHelpers]::OpenProcessToken($procHandle, $access, [ref] $tokenHandle)) {
    throw "OpenProcessToken failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
# Lookup LUID for SeCreateSymbolicLinkPrivilege
$luid = New-Object TokenHelpers+LUID
if (-not [TokenHelpers]::LookupPrivilegeValue($null, "SeCreateSymbolicLinkPrivilege", [ref] $luid)) {
    throw "LookupPrivilegeValue failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
Write-Host "LUID for SeCreateSymbolicLinkPrivilege: $($luid.LowPart) / $($luid.HighPart)"
# Try to enable it
$tp = New-Object TokenHelpers+TOKEN_PRIVILEGES
$tp.PrivilegeCount = 1
$tp.Privileges = New-Object TokenHelpers+LUID_AND_ATTRIBUTES[] 64
$tp.Privileges[0] = New-Object TokenHelpers+LUID_AND_ATTRIBUTES
$tp.Privileges[0].Luid = $luid
$tp.Privileges[0].Attributes = [TokenHelpers]::SE_PRIVILEGE_ENABLED
if (-not [TokenHelpers]::AdjustTokenPrivileges($tokenHandle, $false, [ref] $tp, 0, [IntPtr]::Zero, [IntPtr]::Zero)) {
    throw "AdjustTokenPrivileges failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
$err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
Write-Host "AdjustTokenPrivileges last error: $err (0 means success)"
# Test symlink creation
$target = "C:\Temp\real"
$link   = "C:\Temp\link"
if (-not (Test-Path $target)) {
    New-Item -ItemType Directory -Path $target | Out-Null
}
try {
    New-Item -ItemType SymbolicLink -Path $link -Target $target -Force
    Write-Host "Symlink creation succeeded as SYSTEM."
} catch {
    Write-Host "Symlink creation FAILED: $($_.Exception.Message)"
}

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
