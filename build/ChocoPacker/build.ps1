$ErrorActionPreference="Continue"
New-Item -ItemType Junction -Path $Env:TEMP\ChocoPackerBuild -Value $Env:CODEBUILD_SRC_DIR\build\ChocoPacker
cd $Env:TEMP\ChocoPackerBuild
nuget.exe restore
msbuild /property:OutputPath=$Env:TEMP\ChocoPacker /verbosity:minimal /maxcpucount
cd $Env:CODEBUILD_SRC_DIR
