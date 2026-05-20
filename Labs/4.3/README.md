# Lab 4.3 — Detection-as-Code (Sigma + YARA)

## What this lab is

You are wearing the Blue Team hat at NOVA Corp. Crimson Viper has been knocking on the door for months and your detection logic is scattered across yaml files, hand-written KQL, and brittle scheduled scans. Today you bring it under control: detection rules versioned in git, converted to platform-native query language through a pipeline, and deployed by repeatable scripts. The deliverable at the end of the lab is a git repo — that is the engagement artifact.

You will work with two complementary detection languages:

- **Sigma** for behavioral patterns in logs (a process accessing LSASS memory, a flurry of failed logons against one account, a PowerShell command line containing a download cradle).
- **YARA** for artifact-content matches (the magic bytes of an LSASS minidump on disk, mimikatz signature strings in a binary).

Both fan out into Kibana's Alerts page. The git repo is your source of truth.

## How to run it

1. SSH to your Kali workstation — that's where you'll author and convert Sigma rules and test YARA rules locally.
2. SSH access to `cs\support` (Domain Admin) on both `memberserver` and `dc01` — that's where the YARA endpoint scanner gets deployed.
3. Kibana access at `https://<ELK_IP>:5601` as `elastic` — that's where you import the rules and watch the alerts roll in.

There is no installer to run. The walkthrough below mixes web UI clicks (Uncoder, Kibana) with CLI commands you copy-paste.

## What you will do

The lab has three parts plus a wrap-up:

### Part 0 — Detection-as-Code concepts (10 min)
The case for treating detection rules like application code, and why Sigma + YARA together cover more surface than either alone.

### Part 1 — Sigma block (40 min)
1. **Uncoder.io warm-up.** Paste one Sigma rule into uncoder.io, pick Elastic Stack as the output target, watch the conversion happen in your browser. This is the "wow" moment — same source, multiple SIEM dialects, no manual rewriting.
2. **`sigma-cli` on Kali.** Bulk-convert all three Sigma rules from `sigma/` into Elastic NDJSON. You'll learn that the lucene backend doesn't support correlation rules (yet); for the brute-force rule you switch to the esql backend. This is real DaC: pick the target per rule, not per repo.
3. **Kibana NDJSON import.** In Kibana → Security → Rules → Import. Drop the NDJSON file. All three rules appear in the Installed Rules list with status Enabled.
4. **Telemetry pre-flight.** Two of the rules need telemetry that the AMI baseline disables by default — PowerShell ScriptBlockLogging registry key and Sysmon EID 10 (ProcessAccess) for lsass. You enable both inline. The lesson: a rule without a signal is theater. Always validate that the underlying log source is alive.
5. **Trigger and validate.** Run the scripts in `scripts/trigger-*.ps1` and `scripts/trigger-brute-force.sh` to fire each rule. Alerts roll into Kibana within a few minutes.

### Part 2 — YARA block (40 min)
1. **Author the rules.** Read `yara/credential_dumping.yar`. Two rules — one detects LSASS minidump magic bytes at offset 0, the other detects 2-of-6 mimikatz signature strings in any file. Test them on Kali against the included sample files.
2. **Deploy the endpoint scanner.** Bundle yara64.exe + the rule + the wrapper script into a zip, push to both Windows endpoints, expand into `C:\ProgramData\PT-YARA\`, run `install-yara-scanner.ps1` to register a scheduled task as SYSTEM.
3. **Force-run and observe.** `Start-ScheduledTask PT-YARA-Scan` triggers an immediate scan. Each YARA hit writes EID 1337 to the Application Event Log under source `PT-YARA`. Elastic Agent picks it up automatically — no Fleet changes needed.
4. **Create the Kibana detection rule.** One API call (or the Kibana UI Custom-query rule path) creates a rule on `event.provider:"PT-YARA" AND event.code:"1337"`. YARA hits now show up in the same Alerts page as the Sigma rules from Part 1.

### Part 3 — Git the lot (10 min)
You initialize a git repo, commit the rules + scripts, and push. That repo is the engagement deliverable. Anyone who clones it can re-deploy the exact same detection coverage.

## What you will produce

By the end of the lab you'll have:

- 3 Sigma rules deployed and firing in Kibana (LSASS access, failed-logon brute force, PowerShell suspicious download cradle).
- 1 YARA scheduled task on each Windows endpoint emitting hits to Application Event Log.
- 1 Kibana detection rule fanning out the YARA hits into the Alerts page.
- A git repo with all of the above as the canonical source of truth.

## Files in this repo

```
sigma/
  01-lsass-access-ioa.yml                # Sysmon EID 10 + GrantedAccess masks
  02-failed-logon-brute-force.yml        # Sigma correlation rule (modern syntax)
  03-powershell-suspicious-download.yml  # ScriptBlock keyword match
yara/
  credential_dumping.yar                 # 2 rules: MDMP magic + mimikatz strings
scripts/
  install-yara-scanner.ps1               # Scheduled task installer
  yara-scan.ps1                          # Scheduled task body (the scanner itself)
  trigger-lsass-access.ps1               # Sigma rule #1 trigger
  trigger-ps-download.ps1                # Sigma rule #3 trigger
  trigger-brute-force.sh                 # Sigma rule #2 trigger (run on Kali)
  sysmonconfig-lab43.xml                 # Sysmon config with EID 10 enabled
```

## Pre-flight checklist

Before you run anything else, confirm:

- [ ] Both Windows endpoints already have Elastic Agent + Sysmon + Defender running (delivered by Lab 2.5 AMI baseline).
- [ ] `cs\support` is Domain Admin and you can SSH into both hosts.
- [ ] `PSScriptBlockLogging` registry key is set on both hosts (`HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging=1`).
- [ ] Sysmon config includes ProcessAccess for lsass.exe (see `scripts/sysmonconfig-lab43.xml` — push it with `sysmon64.exe -c sysmonconfig-lab43.xml`).
- [ ] Defender exclusion (or Endpoint policy exclusion on Defend hosts) for `C:\ProgramData\PT-YARA\samples\` — otherwise the test artifacts get quarantined before YARA scans them.
- [ ] SSH against Windows: `-o PreferredAuthentications=password -o PubkeyAuthentication=no` to avoid the "too many auth failures" lockout.

## Why this lab matters

Detection rules written in a `.yml` you can't redeploy are a snowflake. Detection rules in a git repo with a converter pipeline and an installer script are infrastructure. The shift is the same one Ops went through with config-management tools — and SecOps is about ten years behind. The point of this lab is to make that shift, on real telemetry, against a scenario that resembles a real engagement.
