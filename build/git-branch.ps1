$git = "$Env:TEMP\ChocoPackerBuild\packages\Git-Windows-Minimal.2.18.0\tools\cmd\git.exe"

Start-Process -FilePath $git `
    -ArgumentList "branch -a --contains $Env:CODEBUILD_SOURCE_VERSION" `
    -RedirectStandardOutput "$Env:TEMP\git-branch.txt"
    
#$branch = Get-Content "$Env:TEMP\git-branch.txt" | Select -Index 4
$branch = Get-Content "$Env:TEMP\git-branch.txt" -Raw
$Env:CODEBUILD_SOURCE_BRANCH = $branch
Write-Output "$Env:CODEBUILD_SOURCE_BRANCH"
Write-Output "branch $branch"
