# Lab 4.3 - YARA wrapper for scheduled task.
# Runs C:\ProgramData\PT-YARA\yara64.exe against scan paths,
# writes each match to the Windows Application Event Log under source PT-YARA (EID 1337).
# Elastic Agent's `system.application` data stream then ships those events to ES,
# where a Kibana detection rule fires on winlog.provider_name="PT-YARA".

$ErrorActionPreference = 'Continue'
$base       = 'C:\ProgramData\PT-YARA'
$yaraBin    = Join-Path $base 'yara64.exe'
$rulesFile  = Join-Path $base 'rules\credential_dumping.yar'
$scanPaths  = @('C:\ProgramData\PT-YARA\samples')   # extend in production: 'C:\Users\*\Downloads', etc.
$evtSource  = 'PT-YARA'

# Ensure the event source exists (idempotent; harmless if already present).
if (-not [System.Diagnostics.EventLog]::SourceExists($evtSource)) {
    New-EventLog -LogName Application -Source $evtSource
}

# Always log a run-started event so we can verify the task ran even if 0 hits.
Write-EventLog -LogName Application -Source $evtSource -EventId 1300 `
    -EntryType Information -Message "PT-YARA scan starting on $env:COMPUTERNAME (rules: $rulesFile)"

$matchCount = 0
foreach ($p in $scanPaths) {
    if (-not (Test-Path $p)) { continue }
    Get-ChildItem -Path $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $f = $_.FullName
        $out = & $yaraBin -s $rulesFile $f 2>&1
        if ($LASTEXITCODE -eq 0 -and $out) {
            foreach ($line in $out) {
                if ($line -match '^([A-Za-z0-9_]+)\s+(.+)$') {
                    $ruleName = $matches[1]
                    $target   = $matches[2]
                    $msg = "YARA HIT rule=$ruleName target=$target host=$env:COMPUTERNAME"
                    Write-EventLog -LogName Application -Source $evtSource -EventId 1337 `
                        -EntryType Warning -Message $msg
                    $matchCount++
                }
            }
        }
    }
}

Write-EventLog -LogName Application -Source $evtSource -EventId 1301 `
    -EntryType Information -Message "PT-YARA scan finished on $env:COMPUTERNAME. Hits: $matchCount"
