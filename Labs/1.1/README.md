# Lab 1.1 — Purple Team Engagement Planner

## What this lab is

You are stepping into the role of a Purple Team lead at **NOVA Corp**, a mid-large fintech (~3,200 employees, hybrid Azure + on-prem AD, recent IPO, launching crypto custody in 6 months). Your task: build a complete, defensible engagement plan for an upcoming exercise that emulates **Crimson Viper** — a financially motivated, APT-adjacent threat actor known for spear-phishing with AiTM MFA bypass, Kerberos abuse, cloud-staged exfiltration, and ransomware.

The goal of the lab is not to pick the "right answer." It is to make the same decisions a real engagement lead has to make — under realistic pressure, with realistic constraints, and with a curated MITRE ATT&CK loadout that matches the adversary you are emulating.

## How to run it

1. Download or clone this repository.
2. Open **`engagement-planner-v2.html`** in any modern browser (Chrome, Firefox, Edge, Safari). Double-click works — there is no install, no backend, no account.
3. Your progress auto-saves to the browser. Closing the tab is safe; reopening the same browser restores your work.

## What you will do

The wizard walks you through 11 sections. You can revisit any of them at any time using the left-hand navigation:

1. **Briefing** — read NOVA Corp and Crimson Viper background. This is your context for every decision.
2. **Scenario & Objective** — define the engagement objective, success criteria, and choose emulation vs. simulation.
3. **Operation Details** — set engagement dates, points of contact, and escalation paths.
4. **Rules of Engagement** — pick from a curated checklist of standard ROE clauses and add custom ones if needed.
5. **Roles Assignment** — assign Red, Blue, White-cell, and stakeholder roles.
6. **Engagement Narrative** — write the attack story in plain language: how the operation unfolds end-to-end.
7. **Environment Design** — define what is in scope, what is explicitly out of scope, segments involved, and sensors available.
8. **Operation Timeline** — sequence the phases (Recon → Initial Access → Execution → Persistence → Lateral Movement → Collection → Exfiltration → Impact).
9. **Monitoring & Collection** — specify the log sources and baseline detections you expect to lean on.
10. **Expected Adversary Activities** — pick the MITRE ATT&CK TTPs Crimson Viper will use, with per-TTP detail (technique, sub-technique, planned detection).
11. **Review & Export** — verify your plan, then export your work.

## Tabletop injects

Two real-world curveballs auto-fire as you progress — one when you complete the ROE section, another when you complete Environment Design. They simulate things that happen in real engagements (legal pushback, fresh CTI mid-planning). Read each inject carefully and revise the affected sections if your plan needs to adapt.

## What you will produce

When you reach the Review & Export section, you will be able to download:

- A **JSON export** of your complete engagement plan (this becomes the input for Lab 1.2 — the Coverage Analyst).
- A **MITRE ATT&CK Navigator layer** showing your selected TTPs scored by adversary alignment (for visualization in Navigator).
- A **PDF** of the full plan via your browser's Print function.

Save these files — you will need them for the next lab.

## Tips before you start

- **Treat soft validation as a hint, not a gate.** The lab will warn you about incomplete fields but will not stop you from exporting. You are the practitioner; you decide what is "done."
- **Be specific.** "Compromise crown jewels" is a bad objective. "Validate detection of AiTM MFA bypass against three identified high-value M365 accounts within a 5-day window" is a real one.
- **Stay in scope.** Crimson Viper has a defined TTP profile. Picking off-profile TTPs (or RoE-violating ones) costs you points in the scorecard.
- **Read the briefing carefully.** The scenario, the threat actor, and the compliance constraints (PCI-DSS, SOC 2, GDPR, NYDFS) all shape the right answers later.

## Estimated time

45 minutes for an experienced practitioner. Take longer if you want to think it through — the lab does not penalize time spent.
