# # Run as elevated administrator
# $cfg    = "$env:TEMP\secpol.inf"
# $backup = "$env:TEMP\secpol_backup_$(Get-Date -Format yyyyMMdd_HHmmss).inf"
# $right      = 'SeCreateSymbolicLinkPrivilege'
# $adminSid   = '*S-1-5-32-544'  # BUILTIN\Administrators
# $systemSid  = '*S-1-5-18'      # NT AUTHORITY\SYSTEM
# # 1. Export local security policy
# secedit /export /cfg $cfg | Out-Null
# # 2. Backup
# Copy-Item $cfg $backup -Force
# # 3. Read file
# $content = Get-Content $cfg
# # Helper: find line index
# function Get-LineIndex {
#     param($lines, $pattern)
#     for ($i = 0; $i -lt $lines.Count; $i++) {
#         if ($lines[$i] -match $pattern) { return $i }
#     }
#     return $null
# }
# $lineIndex = Get-LineIndex -lines $content -pattern "^$right"
# if ($lineIndex -ne $null) {
#     # Existing line
#     $line   = $content[$lineIndex]
#     $parts  = $line -split '=', 2
#     $values = @()
#     if ($parts.Count -gt 1 -and $parts[1].Trim()) {
#         $values = $parts[1].Split(',') |
#                   ForEach-Object { $_.Trim() } |
#                   Where-Object { $_ -ne '' }
#     }
#     if ($values -notcontains $adminSid)  { $values += $adminSid }
#     if ($values -notcontains $systemSid) { $values += $systemSid }
#     $content[$lineIndex] = "$right = " + ($values -join ',')
# }
# else {
#     # No line yet – add under [Privilege Rights]
#     $privIndex = Get-LineIndex -lines $content -pattern '^\[Privilege Rights\]'
#     if ($privIndex -eq $null) { throw "Could not find [Privilege Rights] section in $cfg" }
#     $newLine = "$right = $adminSid,$systemSid"
#     $before  = $content[0..$privIndex]
#     $after   = $content[($privIndex + 1)..($content.Count - 1)]
#     $content = $before + $newLine + $after
# }
# # 4. Write back
# Set-Content -Path $cfg -Value $content -Encoding Unicode
# Write-Host "Updated $right in $cfg"
# Write-Host "Backup saved as $backup"
# # 5. Apply
# secedit /configure /db secedit.sdb /cfg $cfg /areas USER_RIGHTS | Out-Null
# Write-Host "Policy updated. Logoff/reboot may be required."
