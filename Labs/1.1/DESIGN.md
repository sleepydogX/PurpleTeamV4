# Lab 1.1 — Purple Team Engagement Planner (Design)

**Date:** 2026-05-04
**Status:** Implemented (v1)
**Author:** JawaSec / APT Course

## Purpose

Replace the static Word-doc fill-in exercise with an interactive single-file HTML wizard that walks experienced practitioners through building a realistic Purple Team engagement plan. Output flows directly into Lab 1.2 (ATT&CK Navigator) and Lab 1.4 (VECTR campaign creation).

## Lab Alignment (vs. Course Overview v3)

| v3 Requirement | Implementation |
|---|---|
| 45-min duration | Sectioned wizard, designed to complete in 45 min for experts |
| Day 1 (11:15–12:00) | First lab of the course; no prereqs assumed |
| NOVA/Crimson Viper scenario | Briefing screen pre-loads NOVA Corp + Crimson Viper threat actor profile |
| ROE definition | Curated standard clauses + custom additions |
| Success criteria | Required field in Scenario section |
| Stakeholder alignment | Roles Assignment section |
| Emulation vs simulation | Explicit choice in Scenario section with tooltip |
| Planning frameworks | Implicit through narrative + timeline structure |

## Non-goals

- Multi-user collaboration
- Backend / persistence beyond browser localStorage
- Authentication
- AI assistance inside the wizard
- Mobile responsive layout (desktop classroom only)

## Architecture

**Single self-contained HTML file** with embedded CSS and vanilla JS (no build step, no dependencies). Students open it locally in any modern browser.

### Sections (11 total)

1. **Briefing** — NOVA Corp + Crimson Viper background (read-only)
2. **Scenario & Objective** — engagement objective, success criteria, emulation type
3. **Operation Details** — dates, points of contact, escalation paths
4. **Rules of Engagement** — checklist + custom clauses
5. **Roles Assignment** — standard-role picker + assignees
6. **Engagement Narrative** — story-form attack chain description
7. **Environment Design** — in-scope, out-of-scope, segments, sensors
8. **Operation Timeline** — phased plan (Recon → Initial Access → … → Exfil)
9. **Monitoring & Collection** — log sources + baseline detections
10. **Expected Adversary Activities** — ATT&CK TTP picker (curated for Crimson Viper) + per-TTP detail
11. **Review & Export** — summary, JSON export, Print to PDF

### Tabletop Injects (auto-trigger by progress)

- **Inject 1** — fires when ROE section is marked complete. Legal counsel adds new constraints around PII access and session recording retention.
- **Inject 2** — fires when Environment Design is marked complete. CTI update: Crimson Viper observed using cloud identity attacks (Entra consent grants) at peer org; CISO wants scope expansion.

Inject content surfaces as a modal that students must acknowledge, then highlights the affected sections so they can revise.

### State

- Auto-save to `localStorage` on every field change (debounced 500ms) and on blur
- "Saved Xs ago" status indicator in footer
- "Import JSON" button to load a previously exported plan
- "Reset" button (with confirmation) to clear local state

### Validation

- Soft warnings: each section shows a completion badge in the sidebar (◯ empty / ◐ partial / ● complete)
- "Review & Export" page lists all incomplete required fields but does not block export
- Print/JSON export always available

### Look & Feel

- White base, purple primary (`#5B2C87`), red accent (`#C8102E`), neutral grays
- System UI font stack
- Card-based main panel, slim sidebar nav with progress
- Print CSS: removes nav/buttons, page-break per section, clean per-page header

### Output

**JSON** (VECTR-aligned schema, see `engagement-plan-schema.md`):
```
{
  "engagementPlan": {
    "metadata": {...},
    "scenario": {...},
    "operationDetails": {...},
    "rulesOfEngagement": {...},
    "roles": [...],
    "narrative": "...",
    "environment": {...},
    "timeline": [...],
    "monitoring": {...},
    "ttps": [...]
  }
}
```

**PDF** via browser `window.print()` with print CSS.

## Curated Content

### NOVA Corp (target organization)
- Mid-large fintech, ~3,200 employees, 12 offices NA/EU
- Hybrid: Azure-primary cloud + on-prem AD (single forest, 3 domains)
- Recent IPO, expanding into crypto custody
- 14M customers, ~$2B/day in transactions
- Compliance: PCI-DSS, SOC 2, GDPR, NYDFS 23 NYCRR 500

### Crimson Viper (threat actor)
- Financially motivated, APT-adjacent, active since 2024
- TTP profile: spear-phishing + AiTM MFA bypass; Kerberos abuse; cloud-staged data exfil; ransomware as monetization
- Recent activity: Tier-2 banks and crypto exchanges in EU/NA
- Notable: LOLBins, custom .NET implants, proxy-aware infra

### Curated ATT&CK TTPs (~32, mapped to Crimson Viper)
Spans Initial Access, Execution, Persistence, PrivEsc, Defense Evasion, Credential Access, Discovery, Lateral Movement, Collection, C2, Exfiltration, Impact. Full list embedded in HTML.

### Standard ROE Clauses (15)
Curated checklist covering data protection, scope, communications, escalation, cleanup, IR-precedence, etc.

## Files

- `engagement-planner.html` — the application
- `DESIGN.md` — this document
- `engagement-plan-schema.md` — JSON output schema reference (for Lab 1.4 integration)

## Future Enhancements (out of v1 scope)

- VECTR import endpoint integration (currently student manually imports JSON)
- ATT&CK Navigator pre-fill from selected TTPs
- Instructor dashboard view (would require backend)
- Multi-language (currently English only)
