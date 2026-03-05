# AHSL.ps1
$exe  = "C:\Program Files\ANSYS Inc\v252\Ansys AHSL\Academic Healthcare SimLab.exe"
$url  = "http://127.0.0.1:8051"
$port = 8051

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Create a small "Launching..." window (modeless)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Academic Healthcare SimLab"
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = 'FixedDialog'
$form.ControlBox = $false
$form.Width = 520
$form.Height = 160
$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Left = 20
$label.Top  = 20
$label.Text = "Launching Academic Healthcare SimLab in the background..."
$form.Controls.Add($label)
$label2 = New-Object System.Windows.Forms.Label
$label2.AutoSize = $true
$label2.Left = 20
$label2.Top  = 55
$label2.Text = "Your browser will open automatically when it is ready. May take 2-3 minutes to initialize!"
$form.Controls.Add($label2)
$form.Show()
[System.Windows.Forms.Application]::DoEvents()
# Start the server immediately (no user click required)
Start-Process -FilePath $exe -WindowStyle Hidden | Out-Null
# Wait until the port is listening (up to 180s)
$deadline = (Get-Date).AddSeconds(180)
do {
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.Application]::DoEvents()
    $listening = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue
} until ($listening -or (Get-Date) -gt $deadline)
$form.Close()
