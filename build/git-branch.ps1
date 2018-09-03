$git = "$Env:TEMP\ChocoPackerBuild\packages\Git-Windows-Minimal.2.18.0\tools\cmd\git.exe"
$branch = $(Start-Process -FilePath $git -ArgumentList "symbolic-ref HEAD --short" -NoNewWindow)

if (-Not $branch) {
    $branch = $(Start-Process -FilePath $git -ArgumentList "branch -a --contains HEAD" -NoNewWindow)
}

$Env:CODEBUILD_SOURCE_BRANCH = $branch
