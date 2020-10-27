param([Parameter(Mandatory=$true)] [string]$hostname="", [Parameter(Mandatory=$true)][string]$username="")
# RestApi Powershell Script to enable Apple APNS HTTP2 requirement
# (c) Daniel Weppeler 26.10.2020 v1.00 
# Twitter: https://twitter.com/_DanielWep 
# freeware license

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
$headers = @{}
$base = "https://" + $hostname + ":4443/xenmobile/api/v1"
$password = Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File "$env:TEMP\login.txt"
$password = (Get-Content "$env:TEMP\login.txt") | ConvertTo-SecureString
try {
    $loginbody = '{"login":"' + $username + '","password":"' + [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($password)))) +'"}'
    $session = Invoke-RestMethod -Headers $headers -Uri "$base/authentication/login" -Method Post -Body $loginbody -ContentType 'application/json'
    $auth_token = $session.auth_token
    $headers.Add("auth_token", "$auth_token")
    $restapicmd = Invoke-RestMethod -Uri "$base/serverproperties" -Body '{"name":"apple.apns.http2","value":"true","displayName":"apple.apns.http2","description":"Enable HTTP/2 for APNS"}' -ContentType application/json -Headers $headers -Method Post
    if ($restapicmd.status -eq "0") {
        Write-Host "Status: APNS HTTP2 Server Property successfully installed." -ForegroundColor Green 
        Write-Host "Info: A restart is required for activate this server property." -ForegroundColor Green
    } else {
        Write-Host "Status:" $_.Exception.Response.StatusCode.value__ -ForegroundColor Red
    }

    } catch {
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }