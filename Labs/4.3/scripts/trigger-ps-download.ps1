# Lab 4.3 trigger — PowerShell download cradle (T1059.001 + T1105).
# Uses Net.WebClient + DownloadString, the canonical pattern Sigma rule 03 catches.
$ErrorActionPreference = 'Continue'
Write-Host "[*] PS download cradle on $env:COMPUTERNAME"
try {
    $wc = New-Object Net.WebClient
    # Use a benign internal URL — ELK Kibana login page. We don't care about the response.
    $body = $wc.DownloadString('http://10.16.2.10:9200/')
    Write-Host "[+] DownloadString returned $($body.Length) bytes"
} catch {
    Write-Host "[-] DownloadString error: $_"
}
# Also exercise Invoke-WebRequest pattern
try {
    $r = Invoke-WebRequest -Uri 'http://10.16.2.10:9200/' -UseBasicParsing -TimeoutSec 3
    Write-Host "[+] Invoke-WebRequest status: $($r.StatusCode)"
} catch {
    Write-Host "[-] IWR error: $_"
}
Write-Host "[*] Done at $(Get-Date -Format 'HH:mm:ss')"
