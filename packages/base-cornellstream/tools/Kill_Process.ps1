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

            $runningProcesses | % {If ($process -eq $_.Path -and $_.Name -ne 'powershell'){$found += $_.Name}}

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3gUh7rmzX5/A/Rt1eDFW+XyD
# X+6gghUhMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUcZ8cVDFo2WSxdsOT+YfCHXXEmI0wDQYJKoZIhvcNAQEB
# BQAEggIAYb51l1sNOdYnX8sfbD92QMzCwJRBFH6NqjPxq9FpTJ1/EPHn8akA4VND
# Vo+3LR2EqKUQZ4L9MWw/6cabc8QEr9aJFGnUqRX3FCwgQtILyHOAlqX0g741heAY
# 7R8xH77mS8w1POav5Tp3xGyNAEsdwOJcqi7Al6ux2UUNPVtqumYVlx9WRh0vFbc/
# ILk1yheZYuGk78qo6jKyx6NuEV4Ooq4vbEMdEj/RhjMvxxjvf2kixSMa1DmTZZIZ
# HSu9s4a+NDRmc7JLhvTrCWLduz58nVxxr6PL/HEFqEuAZbc9mgaEHz1eI1q/8fXh
# /q9nTPLon5b0gdMOUtD4AlA8CVDvVKwdsbrUNoJuu9ka9w0aevL7fJN5N/ZAz+jI
# aoGVdsojuvl3GOye/vyjFlTbwUQ6KOpJSpLRHYL6IcCEDrA3papW8cH3KsB+Eqbk
# dF19dAbPP5J2tXiNMlZwtX1A20bRkGF6uqOHGzwHES07DAt7bhX0YKPKnYxkB6u9
# HyVvXXnR3jkQeLY5+7ZLcUEeE+5GhRC/l7VWluz3gv0N99e2eVXdJ7srdke1Ue3B
# T9wKvmeDpawRJ/k5WfWmVzGmVK+opqy/2nKuX4RgKrB1vuaNqTCtl+TPKdubfzpL
# iirPYF5LI1mdU8rbtxJtxoQosu9i4B6yVjJ/bg0mhffsgIrDsfihggILMIICBwYJ
# KoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3Rh
# bXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMC
# GgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MTgxMTA3MTY1OTUzWjAjBgkqhkiG9w0BCQQxFgQUG42Ghx/oZ69AgGQWtM7mE11+
# sMQwDQYJKoZIhvcNAQEBBQAEggEAluOezD6h09nS8rIHjXYiY4zsEzfeQHnrsdO2
# 2XqkJ8AvuC5pjkgciCjhl5TTm7SIKzVL9h7wm9PYric9Yo3s1T8mogZ8WADFJOB7
# dG2Gvl8+zVSi4N37z/lOSte9l751Kcyh9hNR34tjeJpGFztRLi3A8Ywe8Bc4vm5i
# ez9ECO0cgeSDSyERfqj23JVbfHU/hAA3KmcKvkuwNjHef8sBgtGoveISdiGP8yXZ
# h7QBFZYDDsN3Ok785lf8XpkAYR6B60Nfu9WFBTxq8+tlQex/eTmFq8OBu8PcvJ8Q
# vwj1pN1NOrvKhxRdfzflnLYVLWMWFWUnvUOscYAdzKS4zngPrA==
# SIG # End signature block
