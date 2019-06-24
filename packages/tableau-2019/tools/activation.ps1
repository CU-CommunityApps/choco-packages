# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console

# Activate product
Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe" -ArgumentList "-activate $env:STATIC_SYSTEM_TABLEAU_ACTIVATE_KEY";Start-Process "$env:ProgramFiles\Tableau\Tableau 2019.2\bin\tableau.exe"
