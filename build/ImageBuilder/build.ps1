$ErrorActionPreference="Continue"
New-Item -ItemType Junction -Path $Env:TEMP\ImageBuilderBuild -Value $Env:CODEBUILD_SRC_DIR\build\ImageBuilder
cd $Env:TEMP\ImageBuilderBuild
nuget.exe restore
msbuild /property:OutputPath=$Env:CODEBUILD_SRC_DIR\packages\image-builder-cornell\tools\ImageBuilder /verbosity:minimal /maxcpucount
cd $Env:CODEBUILD_SRC_DIR
