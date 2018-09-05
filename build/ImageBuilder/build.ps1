New-Item -ItemType Junction -Path $Env:TEMP\ImageBuilderBuild -Value $Env:CODEBUILD_SRC_DIR\build\ImageBuilder
cd $Env:TEMP\ImageBuilderBuild
nuget.exe restore
msbuild /p:OutputPath=$Env:CODEBUILD_SRC_DIR\packages\_image-builder\tools\ImageBuilder
cd $Env:CODEBUILD_SRC_DIR
