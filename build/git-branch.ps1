$git = "$Env:TEMP\ChocoPackerBuild\packages\Git-Windows-Minimal.2.18.0\tools\cmd\git.exe"

Start-Process -FilePath $git `
    -ArgumentList "symbolic-ref HEAD --short" `
    -RedirectStandardOutput "$Env:TEMP\git-branch.txt"

$branch = Get-Content "$Env:TEMP\git-branch.txt"

if (-Not $branch) {
    Start-Process -FilePath $git `
        -ArgumentList "branch -a --contains HEAD" `
        -RedirectStandardOutput "$Env:TEMP\git-branch.txt"
        
    $branch = (Get-Content "$Env:TEMP\git-branch.txt")[1]
}

$Env:CODEBUILD_SOURCE_BRANCH = $branch
Write-Output $Env:CODEBUILD_SOURCE_BRANCH
