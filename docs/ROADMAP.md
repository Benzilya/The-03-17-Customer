# The 03:17 Customer — Production Roadmap

## Current overall progress: ~61%

M1–M8 are implementation-complete. M9 now has Night 2, interactive evidence checks, serve/refuse scoring, and visible environmental consequences for wrong decisions. M8 still needs final recorded-SFX replacement/listening QA, but it no longer blocks content development.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix structure and 03:17 audio direction (6%) — IMPLEMENTATION COMPLETE / RECORDED-SFX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics (7%) — IN PROGRESS (~65% of milestone)
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
- Evidence is now inspected source-by-source; decision is locked until all three sources are checked.
- Serve/refuse scoring and Night 3 progression save.
- Main-menu Continue routes saved Night 2 progression correctly.
- Wrong decisions now cause a visible verification warning, lighting flicker and a cumulative darker store state.
- Correct decisions receive a short green verification confirmation without horror escalation.

## Remaining M9 work
1. Move at least one evidence source from terminal-only presentation into a physical in-world interaction.
2. Add a dedicated CCTV contradiction view for Night 2 rather than text only.
3. Carry wrong-decision count into Night 3 save data and future consequences.
4. Add Night 2 customer-approach/atmosphere polish.
5. Godot runtime QA at 1280x720 in RU and EN.

## Audio note
The project is prepared to use recorded CC0 files from `assets/audio/cc0/`; synthetic ordinary SFX remain temporary fallback until the selected binaries are physically imported. Supernatural 03:17 design can remain procedural where intentional.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, after final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
