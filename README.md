# PurpleTeamV4

Public companion artifacts for the **Advanced Purple Team Course (2026, v4)** delivered by JawaSec.

This repository publishes the interactive lab artifacts so students and the wider community can download and run them locally — no install required, just open the HTML in a browser.

## Available labs

### Lab 1.1 — Engagement Planner (`Labs/1.1/`)

A single-file, self-contained HTML wizard that walks an analyst through scoping a Purple Team engagement against a fictional fintech (NOVA Corp) facing an APT-adjacent adversary (Crimson Viper).

- **`engagement-planner-v2.html`** — the lab itself. Open it in any modern browser (Chrome, Firefox, Edge, Safari). State persists in `localStorage`. No backend, no installs, no telemetry.
- **`DESIGN.md`** — design notes: scoring model, sections, throughline to downstream labs.

**Outputs:**
- `lab-1.1-state.json` — full export consumed by Lab 1.2 (Coverage Analyst).
- `lab-1.1-attack-navigator-layer.json` — MITRE ATT&CK Navigator 4.5 layer with TTP scoring for the adversary.

## How to use

1. Download or clone this repo.
2. Open `Labs/1.1/engagement-planner-v2.html` directly in your browser (double-click works).
3. Walk through the sections, save your exports.

## License & usage

These artifacts are published for educational and training use. Redistribution as part of paid commercial training requires permission — reach out to JawaSec.

## Course context

The full 10-day course covers: BAS introduction, planning & mapping, VECTR, AI/RAG workflow, CTI & MISP, detection baseline, 18 offensive sub-modules (Atomic Red Team through cloud identity attacks), and advanced detection engineering with Sigma, Suricata, YARA and detection validation.

This repo will grow as additional labs are released.
