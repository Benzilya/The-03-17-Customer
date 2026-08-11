# The 03:17 Customer — Production Roadmap

## Current overall progress: ~63%

M1–M8 are implementation-complete. M9 now has a playable Night 2 loop with source-by-source anomaly verification, in-world evidence stations, visible consequences and persistent carryover into Night 3. Final M9 work is atmosphere polish plus real Godot RU/EN runtime QA.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix structure and 03:17 audio direction (6%) — IMPLEMENTATION COMPLETE / RECORDED-SFX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics (7%) — IN PROGRESS (~85% of milestone)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M9 implemented so far
- Standalone `scenes/night2.tscn` using the first-person controller.
- Four Night 2 customer cases: two normal and two anomalous.
- Bilingual anomaly-verification terminal.
- Evidence must be checked source-by-source before the decision unlocks.
- In-world evidence layer adds CCTV, register/log and refrigerator/reflection checking points.
- CCTV contradictions can disagree with the physically visible customer.
- Serve/refuse scoring with visible correct/error feedback.
- Wrong calls trigger lighting instability and a cumulative darker store state.
- Main-menu Continue routes Night 2 progression correctly.
- Night 2 now persists `night_2_wrong`, `threat_level`, `ignored_anomaly` and a Night 3 opening-state key in `save.json`.
- Threat carryover states: clean shift, minor breach, active breach and critical breach.

## Remaining M9 work
1. Night 2 atmosphere/customer-approach polish.
2. Verify physical evidence interaction distance/readability in real Godot play.
3. Verify save merge after Night 2 and Continue routing.
4. Full 1280x720 runtime QA in Russian and English; fix parser/runtime/UI blockers.

## Audio note
The project is prepared to use recorded CC0 files from `assets/audio/cc0/`; synthetic ordinary SFX remain temporary fallback until selected binaries are physically imported. Supernatural 03:17 design can remain procedural where intentional.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, after final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
