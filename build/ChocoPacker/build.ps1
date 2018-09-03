New-Item -ItemType Junction -Path $Env:TEMP\ChocoPackerBuild -Value $Env:CODEBUILD_SRC_DIR\build\ChocoPacker
cd $Env:TEMP\ChocoPackerBuild
nuget.exe restore
msbuild /p:OutputPath=$Env:TEMP\ChocoPacker
cd $Env:CODEBUILD_SRC_DIR
