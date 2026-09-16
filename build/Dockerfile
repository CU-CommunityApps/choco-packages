# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:4.8

SHELL ["C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NUGET_VERSION=7.9.0

# Install NuGet CLI
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    New-Item -ItemType Directory -Force -Path "$Env:ProgramFiles\NuGet" | Out-Null; `
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri "https://dist.nuget.org/win-x86-commandline/v$Env:NUGET_VERSION/nuget.exe" `
        -OutFile "$Env:ProgramFiles\NuGet\nuget.exe"; `
    if (!(Test-Path "$Env:ProgramFiles\NuGet\nuget.exe")) { `
        throw 'NuGet installation failed' `
    }

# Install Visual Studio 2022 Build Tools
RUN $ErrorActionPreference = 'Stop'; `
    $installer = Join-Path $Env:TEMP 'vs_BuildTools.exe'; `
    $logDir = 'C:\vslogs'; `
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null; `
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' `
        -OutFile $installer; `
    $arguments = @( `
        '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', `
        '--add', 'Microsoft.Net.Component.4.8.TargetingPack', `
        '--quiet', `
        '--wait', `
        '--norestart' `
    ); `
    Write-Host 'Installing Visual Studio Build Tools...'; `
    $process = Start-Process `
        -FilePath $installer `
        -ArgumentList $arguments `
        -NoNewWindow `
        -Wait `
        -PassThru; `
    Write-Host "Installer exit code: $($process.ExitCode)"; `
    if ($process.ExitCode -notin @(0, 3010)) { `
      Write-Host 'Visual Studio installation failed. Dumping setup logs...'; `
      $logs = Get-ChildItem `
        -Path 'C:\vslogs', $Env:TEMP `
        -Filter '*.log' `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue `
        | Sort-Object LastWriteTime; `
      foreach ($log in $logs) { `
        Write-Host "===== $($log.FullName) ====="; `
        Get-Content $log.FullName -Tail 200 -ErrorAction SilentlyContinue `
      }; `
      throw ('Visual Studio Build Tools installation failed with exit code {0}' -f $process.ExitCode) `
    }; `
    Remove-Item -Force $installer

# Set PATH for NuGet, MSBuild, and the test platform
ENV PATH="C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\Extensions\TestPlatform"
