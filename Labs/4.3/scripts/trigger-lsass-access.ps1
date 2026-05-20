# Lab 4.3 trigger — opens a handle to LSASS. Sysmon EID 10 records the GrantedAccess mask.
# Touching .Handle on a Process object forces OpenProcess with PROCESS_ALL_ACCESS (0x1FFFFF),
# which is in the Sigma rule's suspicious-mask list — no PInvoke required.
Write-Host "[*] LSASS access trigger on $env:COMPUTERNAME"
$p = Get-Process lsass
Write-Host "[+] LSASS PID: $($p.Id)"
try {
    $h = $p.Handle
    Write-Host "[+] Got handle: $h"
} catch {
    Write-Host "[-] Handle access failed: $_"
}
Write-Host "[*] Done"
