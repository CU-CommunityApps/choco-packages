<#
.SYNOPSIS
    AppStream 2.0 kill processes script
.DESCRIPTION
    Provide a tool for users to force quit hung processes within a streaming instance
.LINK
    https://github.com/CU-CommunityApps/choco-packages
    https://confluence.cornell.edu/display/CLOUD/Cornell+Stream
.NOTES
    This script is launched as a published application in AppStream
#>
$packageLoc = "C:\ProgramData\chocolatey\lib"
$apps = gci "$env:ALLUSERSPROFILE\chocolatey\lib" -Filter "config.json" -Recurse

Function Apps {
    
    $runningProcesses = get-process
    $found = @()

    $apps | % {
    
        $CONFIG = Get-Content -Raw -Path $_.FullName -ErrorAction Stop | ConvertFrom-Json
        
        $publishedApp = ($CONFIG.Applications | get-member -ErrorAction SilentlyContinue | where {$_.MemberType -eq "NoteProperty"}).Name
        
        $publishedApp | % {
            
            $process = [Environment]::ExpandEnvironmentVariables($CONFIG.Applications.$_.Path).Replace('%%', '%')
        
            $process = $process -replace "'"

            $runningProcesses | % {If ($process -eq $_.Path){$found += $_.Name}}

        }
    }

    If ($found){Stop($found)}
    Else {Write-Host "No running applications found" -ForegroundColor Green;exit 0}
}

Function Stop($found) {

    Write-Host "Running Applications Found"

    $found | select -Unique | % {write-host $_ -ForegroundColor Yellow}

    Do {
        
        $processToStop = Read-Host "Enter the process name to stop (in yellow, above)"

    }Until($found -contains $processToStop)

    Write-Host "You are about to force close $processToStop" -ForegroundColor Yellow

    Do {

        $ans = Read-Host "Are you sure? (y or n)"

    }Until($ans.ToLower() -eq "y" -or $ans.ToLower() -eq "n" -or $ans.ToLower() -eq "yes" -or $ans.ToLower() -eq "no")

    If ($ans.ToLower() -eq "y" -or $ans.ToLower() -eq "yes"){
    
        get-process | where {$_.Name -eq $processToStop} | Stop-Process -Force
        If ($? -eq $true){Write-Host "Killing process $processToStop" -ForegroundColor Red;pause;More}
        Else {Write-Host "Failed to stop $processToStop, trying again...";Apps}
    }

    Else {More}

}

Function More {

    Do {

        $ans = Read-Host "Close more apps? (y or n)"

    }Until($ans.ToLower() -eq "y" -or $ans.ToLower() -eq "n" -or $ans.ToLower() -eq "yes" -or $ans.ToLower() -eq "no")
    
    If ($ans.ToLower() -eq "y" -or $ans.ToLower() -eq "yes"){Apps}
    Else {exit 0}

}

Apps
# SIG # Begin signature block
# MIIa8QYJKoZIhvcNAQcCoIIa4jCCGt4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULWThUi0V8KoZceRJ+6sbQTq4
# /sCgghUhMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggXrMIID06ADAgECAhBl4eLj1d5QRYXzJiSABeLUMA0GCSqGSIb3DQEBDQUAMIGI
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVy
# c2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UE
# AxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xNDA5
# MTkwMDAwMDBaFw0yNDA5MTgyMzU5NTlaMHwxCzAJBgNVBAYTAlVTMQswCQYDVQQI
# EwJNSTESMBAGA1UEBxMJQW5uIEFyYm9yMRIwEAYDVQQKEwlJbnRlcm5ldDIxETAP
# BgNVBAsTCEluQ29tbW9uMSUwIwYDVQQDExxJbkNvbW1vbiBSU0EgQ29kZSBTaWdu
# aW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwKAvix56u2p1
# rPg+3KO6OSLK86N25L99MCfmutOYMlYjXAaGlw2A6O2igTXrC/Zefqk+aHP9ndRn
# ec6q6mi3GdscdjpZh11emcehsriphHMMzKuHRhxqx+85Jb6n3dosNXA2HSIuIDvd
# 4xwOPzSf5X3+VYBbBnyCV4RV8zj78gw2qblessWBRyN9EoGgwAEoPgP5OJejrQLy
# Amj91QGr9dVRTVDTFyJG5XMY4DrkN3dRyJ59UopPgNwmucBMyvxR+hAJEXpXKnPE
# 4CEqbMJUvRw+g/hbqSzx+tt4z9mJmm2j/w2nP35MViPWCb7hpR2LB8W/499Yqu+k
# r4LLBfgKCQIDAQABo4IBWjCCAVYwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd
# 8rIDZsswHQYDVR0OBBYEFK41Ixf//wY9nFDgjCRlMx5wEIiiMA4GA1UdDwEB/wQE
# AwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBEG
# A1UdIAQKMAgwBgYEVR0gADBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVz
# ZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5j
# cmwwdgYIKwYBBQUHAQEEajBoMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0
# cnVzdC5jb20vVVNFUlRydXN0UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGG
# GWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQENBQADggIBAEYs
# tn9qTiVmvZxqpqrQnr0Prk41/PA4J8HHnQTJgjTbhuET98GWjTBEE9I17Xn3V1yT
# phJXbat5l8EmZN/JXMvDNqJtkyOh26owAmvquMCF1pKiQWyuDDllxR9MECp6xF4w
# nH1Mcs4WeLOrQPy+C5kWE5gg/7K6c9G1VNwLkl/po9ORPljxKKeFhPg9+Ti3JzHI
# xW7LdyljffccWiuNFR51/BJHAZIqUDw3LsrdYWzgg4x06tgMvOEf0nITelpFTxqV
# vMtJhnOfZbpdXZQ5o1TspxfTEVOQAsp05HUNCXyhznlVLr0JaNkM7edgk59zmdTb
# SGdMq8Ztuu6VyrivOlMSPWmay5MjvwTzuNorbwBv0DL+7cyZBp7NYZou+DoGd1lF
# ZN0jU5IsQKgm3+00pnnJ67crdFwfz/8bq3MhTiKOWEb04FT3OZVp+jzvaChHWLQ8
# gbCORgClaZq1H3aqI7JeRkWEEEp6Tv4WAVsr/i7LoXU72gOb8CAzPFqwI4Excdrx
# p0I4OXbECHlDqU4sTInqwlMwofmxeO4u94196qIqJQl+8Sykl06VktqMux84Iw3Z
# QLH08J8LaJ+WDUycc4OjY61I7FGxCDkbSQf3npXeRFm0IBn8GiW+TRDk6J2XJFLW
# EtVZmhboFlBLoUlqHUCKu0QOhU/+AEOqnY98j2zRMIIGlTCCBX2gAwIBAgIRANP6
# W+QOtLGhIidTCoxRmo0wDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxCzAJ
# BgNVBAgTAk1JMRIwEAYDVQQHEwlBbm4gQXJib3IxEjAQBgNVBAoTCUludGVybmV0
# MjERMA8GA1UECxMISW5Db21tb24xJTAjBgNVBAMTHEluQ29tbW9uIFJTQSBDb2Rl
# IFNpZ25pbmcgQ0EwHhcNMTcwMzIyMDAwMDAwWhcNMjAwMzIxMjM1OTU5WjCBrjEL
# MAkGA1UEBhMCVVMxDjAMBgNVBBEMBTE0ODUwMQswCQYDVQQIDAJOWTEPMA0GA1UE
# BwwGSXRoYWNhMRYwFAYDVQQJDA0xMjAgTWFwbGUgQXZlMRswGQYDVQQKDBJDb3Ju
# ZWxsIFVuaXZlcnNpdHkxHzAdBgNVBAsMFkNlcnRpZmljYXRlIE1hbmFnZW1lbnQx
# GzAZBgNVBAMMEkNvcm5lbGwgVW5pdmVyc2l0eTCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAMwM7Qlu+xk8DWLdcnE9qyZ0qxe+1LAUtJmNpsxAspkdVW8N
# TkeaRVjrHL2xPuBFiVu5B0v/COhe/9WG9Qld4ChvyluC/T/dAFQz13m5jbWTvP2k
# 1mGxueEZhgf0D6/GIiCngml40ftQl2GPjLtgBXyBX0U19s7iijWcnC2HZgzAs3zo
# 4u3Tvm7fS+sQdyohMa6g/CW5hjpsAsTLTse6OzkwC8RPCxmaXjx/W85cO2SE13lW
# T7zAwLeVh09d0B8jfetG8qlORYemB9oGaMrbeErRlFPVblIan6mkSb0aqKjsUgjJ
# 0MZL7VmttCClq8xd6D+d1kPpsLWMfa2ro4ymWsvhMTjYTUIe9nYBBZzFIh45pMWE
# IriPjxbquWZEfHTcKjA3UdzQUD1EwuktDGqWIVfBOMmEnwoxlkeCKPa6OX/aI3iB
# pUJlpnhRHtNeP133GQyngJ60rsk0fZfeXca1TZ9LsrYQRmdaOapbZZ1fV0AGprB5
# wXkpROZcOfx9uS5Ir5IC7lcf5cQObEr1PHljN1jQ4D9aK4w/zCyt/Ima0ur95IRQ
# c85K40NPuBVj2q9IJg8mU05l+3pguceAqjvPr+YvHAtF4eeRRrQQt7C9ujvt9JZ+
# dWFhzdENnUsMXIeqe1PZgDr7RlvN20oMts9Z1XSADpLYUscVw9p1Jqvf0Z1RAgMB
# AAGjggHdMIIB2TAfBgNVHSMEGDAWgBSuNSMX//8GPZxQ4IwkZTMecBCIojAdBgNV
# HQ4EFgQUh5kuVpfid00rL3+cstmejhkUsWEwDgYDVR0PAQH/BAQDAgeAMAwGA1Ud
# EwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQ
# MGYGA1UdIARfMF0wWwYMKwYBBAGuIwEEAwIBMEswSQYIKwYBBQUHAgEWPWh0dHBz
# Oi8vd3d3LmluY29tbW9uLm9yZy9jZXJ0L3JlcG9zaXRvcnkvY3BzX2NvZGVfc2ln
# bmluZy5wZGYwSQYDVR0fBEIwQDA+oDygOoY4aHR0cDovL2NybC5pbmNvbW1vbi1y
# c2Eub3JnL0luQ29tbW9uUlNBQ29kZVNpZ25pbmdDQS5jcmwwfgYIKwYBBQUHAQEE
# cjBwMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0LmluY29tbW9uLXJzYS5vcmcvSW5D
# b21tb25SU0FDb2RlU2lnbmluZ0NBLmNydDAoBggrBgEFBQcwAYYcaHR0cDovL29j
# c3AuaW5jb21tb24tcnNhLm9yZzAeBgNVHREEFzAVgRNrbGluZ2VyQGNvcm5lbGwu
# ZWR1MA0GCSqGSIb3DQEBCwUAA4IBAQAPnnAH9Og/5gAmdw2jcgyrdhWoO7StuJnw
# lxI8lCCMH52iQ7KYoAgEOvR/ph31gFJKGo4TZJLfGwbY1ecszLV8XpRjP6eIERgJ
# xLg968UGTjIEPdCkhiwTuhxlDOqAQbUhs7UlVCgkjkyfSsarrDG8uLg3mLCnp+3L
# N31F6QtQvFV3hGcydRI2FiGSYmsbFtt5xUwkmnJguFdPpZ4SBf6RbVJAO8NjhlQI
# ACYrMxUC4FvwWaGxCYkQkK9Vte9Hsfif2XNMLIVoKQ4hC0warcka3ywCOUeu6J/x
# GuwVIIU+8kAJAyaqr1HQ+lhasTSdlKeteHSqzPIM12zx3B/pyYZ1MYIFOjCCBTYC
# AQEwgZEwfDELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAk1JMRIwEAYDVQQHEwlBbm4g
# QXJib3IxEjAQBgNVBAoTCUludGVybmV0MjERMA8GA1UECxMISW5Db21tb24xJTAj
# BgNVBAMTHEluQ29tbW9uIFJTQSBDb2RlIFNpZ25pbmcgQ0ECEQDT+lvkDrSxoSIn
# UwqMUZqNMAkGBSsOAwIaBQCgcDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUTj1Bn5+h71OqWnUVm0arjy9C0eswDQYJKoZIhvcNAQEB
# BQAEggIAmvCswBa2zKgsHtzdTOWfxDfLlU+ENv8kei6esnqy+T9eW/PFjubMggC+
# cg1n/J17K3/1qSQZZkGR3DOFwtu/Y6waGAe6XT5wUVTTGpM8f2+JCXbIb7NyZDdN
# uhzil17KfJ3KQ7aLyvVBSlQQj9y3r2Ztj91htp8Kzgy05gFsIN0bRPKbi4OUXA6K
# ZSvM/w4WUYyXHpRnZxd6FHOHDIdOqdEJ2ky8/hv/ESV+/xE7w/YepHaWNDEaTTNV
# e6RWNqjedvHv5/OxLf3eEvT71qj2puizWBy1R467MLh3CKJg2Y41Coi3jYNN2XMA
# vTQM7xeOWLay0PYHjr+hIEQdc8Hew1WW76ya4obd2+8UN0VA21ejNt3Ct5ezELJb
# 9Xl3hRIwSu4Qg6rPV6Ldsm6/xJ5GoAv9ogqgfmEMtsLUqvYaClgeqifLdEuPgCgC
# TEWE2ySN00pKK0sIWfE9wVg7L+HRwu4j9Cljzph3JN3vj9txiP3FrPu1Q8BhfHcf
# 7ZijGRKb4zY+iI/yrCWBUWlyI4+Fn46kDcAnI0r84RqMCdTN3obezSqcCT2rAdcE
# xOzePsxgTrxCmFzVUZn6Ui0xPinJZ342OS4K+edWVT9RjlfxiJdBqI3U9KeV9JIa
# 7uJYbVy7n6zLCE0xwQybaNoBq2Feg/M2dWKAPGndFbQTjyAYlv2hggILMIICBwYJ
# KoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3Rh
# bXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMC
# GgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MTgxMTAyMTgxNjUzWjAjBgkqhkiG9w0BCQQxFgQU0efE55a8BzrmTYbBqlI3CHcH
# vuswDQYJKoZIhvcNAQEBBQAEggEAdNI6+mVo9JTj9l68uXArBJMdP/acDTf2TWVo
# RtoIqYvul2FHf5tx2eeeBDzS6ZMnCimOe7DsAz/B5gitdtsXR2pWElScRqkTeqxZ
# VdxvoTym+j5FZUoGX9nAjYRfDyi4V3eH6Q31iI43G+5wTkO/OzjwM3sE8DlpMPT5
# SZSXXz5Z2WR6QPLD0N2uiqWpHRKHFqnUCFqs9Raei+7PPwotgfE5RAozq0IQzKv6
# /aS5yqJnpJ1kIU06H1JSpuLYIso1/IB34em0Xp//6JPaprhN5U57quZ8rv9RXlgC
# FQhoXQ40Vw8aTbDJHHPyakwXX9RKXoSb3hY5iyVIWvjeHe2aVQ==
# SIG # End signature block
