# The 03:17 Customer — Production Roadmap

## Current overall progress: ~59%

M1–M8 are implementation-complete. M9 has started with a playable Night 2 scene, four customer cases, evidence review and serve/refuse decisions. M8 still needs final recorded-SFX replacement/listening QA, but it no longer blocks gameplay content work.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix structure and 03:17 audio direction (6%) — IMPLEMENTATION COMPLETE / RECORDED-SFX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics (7%) — IN PROGRESS (~40% of milestone)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M9 implemented so far
- Added standalone `scenes/night2.tscn` using the existing first-person controller.
- Added four Night 2 customer cases: two normal and two anomalous.
- Added bilingual evidence terminal with CCTV/physical/behavior contradictions.
- Added repeatable serve/refuse decision loop and correctness scoring.
- Night 2 writes progression to Night 3 after all four cases.
- Main menu Continue now reads `save.json` progression and routes Night 2 correctly after completing Night 1.
- New Game clears old JSON progression so a fresh run really starts at Night 1.

## Remaining M9 work
1. Replace the current evidence text terminal with real camera/scene interactions rather than all clues being presented at once.
2. Add one inspectable physical clue in the store (reflection/receipt/timestamp) and one CCTV-only contradiction.
3. Add Night 2 audio/lighting progression and customer approach presentation.
4. Add consequence variables that carry wrong decisions into Nights 3–4.
5. Godot runtime QA for Night 2 at 1280x720 in RU and EN.

## Audio note
The project is prepared to use recorded CC0 files from `assets/audio/cc0/`; synthetic ordinary SFX remain temporary fallback until the selected binaries are physically imported. Supernatural 03:17 design can remain procedural where intentional.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, after final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
