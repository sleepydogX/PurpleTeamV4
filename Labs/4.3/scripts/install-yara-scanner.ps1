# Lab 4.3 — Install the PT-YARA scanner on a Windows endpoint.
# 1) Lays out C:\ProgramData\PT-YARA\{rules,samples,bin} folder structure.
# 2) Drops yara64.exe + credential_dumping.yar + yara-scan.ps1.
# 3) Adds Defender exclusion so the planted samples don't get quarantined before YARA scans them.
# 4) Registers a scheduled task running as SYSTEM, hourly + at start, with one extra trigger 30s from now for first-boot validation.

param(
    [string]$BasePath = 'C:\ProgramData\PT-YARA'
)

$ErrorActionPreference = 'Stop'

# 1) layout
$null = New-Item -ItemType Directory -Force -Path $BasePath, "$BasePath\rules", "$BasePath\samples", "$BasePath\bin"

# 2) bins + rules (uploaded separately via scp into $BasePath before this runs)
#    We just verify presence here.
foreach ($req in @("$BasePath\yara64.exe", "$BasePath\rules\credential_dumping.yar", "$BasePath\yara-scan.ps1")) {
    if (-not (Test-Path $req)) { throw "Missing required file: $req - scp it first." }
}

# 3) Defender exclusion for the samples dir (only relevant on dc01 where Defender is active;
#    on memberserver Defender feature is uninstalled so this is a no-op via try/catch).
try {
    Add-MpPreference -ExclusionPath "$BasePath\samples" -ErrorAction Stop
    Write-Host "[+] Defender exclusion added for $BasePath\samples"
} catch {
    Write-Host "[*] Skipping Defender exclusion ($($_.Exception.Message))"
}

# 4) scheduled task: SYSTEM, hourly + at startup + extra one-shot 30s from now
$taskName = 'PT-YARA-Scan'

# Remove any previous task to keep this script idempotent.
Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

$action  = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BasePath\yara-scan.ps1`""
$triggers = @(
    (New-ScheduledTaskTrigger -AtStartup),
    (New-ScheduledTaskTrigger -Daily -At 02:00),
    (New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30))
)
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers `
    -Principal $principal -Settings $settings -Description "Lab 4.3 PT-YARA endpoint scanner - emits hits to Application/PT-YARA event source."

Write-Host "[+] Scheduled task '$taskName' registered. First run in ~30s."
