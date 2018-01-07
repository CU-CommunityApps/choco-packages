# Runs after the choco package is installed

$papercutConfig = Join-Path $env:TOOLS_DIR 'papercut-startup.xml'

Register-ScheduledTask `
    -TaskName "Papercut Startup" `
    -Xml (Get-Content $papercutConfig | Out-String)

