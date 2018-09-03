$git = "$Env:TEMP\ChocoPackerBuild\packages\Git-Windows-Minimal.2.18.0\tools\cmd\git.exe"

Start-Process -FilePath $git `
    -ArgumentList "symbolic-ref $Env:CODEBUILD_SOURCE_VERSION --short" `
    -RedirectStandardOutput "$Env:TEMP\git-branch.txt"

$branch = Get-Content "$Env:TEMP\git-branch.txt"

#if (-Not $branch) {
#    $branch = $(Start-Process -FilePath $git -ArgumentList "branch -a --contains HEAD" -NoNewWindow)
#}

Write-Output $Env:CODEBUILD_SOURCE_BRANCH
$Env:CODEBUILD_SOURCE_BRANCH = $branch
