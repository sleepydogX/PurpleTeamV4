/*
   Lab 4.3 — Detection-as-Code YARA rules
   Author: JawaSec Purple Team (APT2026)
   Target artifacts:
     - LSASS minidump files dropped by procdump / comsvcs.dll MiniDump
     - Mimikatz-derived strings appearing in binaries or memory dumps
   Pedagogy: behavior-agnostic content match — fires on artifact presence, not on process behavior.
*/

rule Lab43_LSASS_Minidump_Header
{
    meta:
        author      = "JawaSec Purple Team — APT2026"
        description = "Flags any file beginning with the Minidump (MDMP) magic. LSASS dumps look exactly the same to YARA as a debugger crash dump — the FP rate is bounded by where you scan."
        reference   = "https://learn.microsoft.com/en-us/windows/win32/api/minidumpapiset/ns-minidumpapiset-minidump_header"
        attack      = "T1003.001"
        severity    = "high"
        date        = "2026-05-20"
    strings:
        $magic = { 4D 44 4D 50 93 A7 }   // 'MDMP' + version bytes
    condition:
        $magic at 0
}

rule Lab43_Mimikatz_Strings
{
    meta:
        author      = "JawaSec Purple Team — APT2026"
        description = "Flags files containing Mimikatz signature strings — present in both compiled binaries and most LSASS-credential-dumping outputs."
        reference   = "https://github.com/gentilkiwi/mimikatz"
        attack      = "T1003.001"
        severity    = "high"
        date        = "2026-05-20"
    strings:
        $s1 = "sekurlsa::logonpasswords" ascii nocase
        $s2 = "kerberos::list" ascii nocase
        $s3 = "lsadump::sam" ascii nocase
        $s4 = "privilege::debug" ascii nocase
        $s5 = "gentilkiwi" ascii nocase
        $s6 = "mimikatz" ascii nocase
    condition:
        2 of them
}
