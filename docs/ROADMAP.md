# The 03:17 Customer — Production Roadmap

## Current overall progress: ~71%

M1–M8 are implementation-complete. M9 is feature-complete and awaiting final Godot QA. M10 is in active development: Night 3 now has two distinct contradiction cases, completion routing, and a Night 4 scene that consumes inherited memory/threat state.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix structure and 03:17 audio direction (6%) — IMPLEMENTATION COMPLETE / RECORDED-SFX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics (7%) — FEATURE COMPLETE / GODOT QA PENDING (~95%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — IN PROGRESS (~55%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M9 feature-complete scope
- Night 2 with four customer cases, physical verification stations, CCTV contradictions, scoring, consequences and Night 3 persistence.
- Russian/English gameplay path.
- Final closure still requires one real Godot 4.7.x QA pass.

## M10 implemented so far
- Night 3 reads `threat_level` and `night_3_opening` from Night 2 save data.
- First Night 3 case compares LIVE CCTV against archive footage; trusted source changes with inherited threat state.
- Second Night 3 case deliberately makes both CCTV records agree, forcing the player to use a paper receipt / physical register record as an independent truth source.
- Night 3 stores both decisions and advances save progression to Night 4 after the second case and late-shift completion point.
- Night 4 route is derived from Night 3 reliability plus inherited threat: `stable_memory`, `uncertain_memory`, or `contaminated_memory`.
- Night 4 scene exists and changes opening, one aisle position, atmosphere and early story events based on that route.
- Main-menu Continue now routes Night 1 → 2 → 3 → 4 from `save.json`.
- Full RU/EN presentation for current Night 3/4 framework.

## Verification performed this pass
- Confirmed `scenes/night3.tscn` references the archive controller and first-person player correctly.
- Reviewed `night3_archive_system.gd` save writes, threat branching and interaction gating; no obvious static blocker found.
- Identified and fixed a design weakness: archive-versus-live could otherwise become a closed-system guess, so Night 3 now includes an independent physical truth case.

## Next M10 work
1. Add Night 4's active memory-verification mechanic instead of only timed story events.
2. Add a Night 4 customer whose identity changes between the player's written note, live view and archive.
3. Add lore fragment progression explaining why 03:17 appears in recordings before events occur.
4. Complete Night 4 and save routing toward Night 5.
5. Godot QA for Nights 2–4 at 1280x720 in RU and EN.

## Audio note
Recorded CC0 ordinary SFX are still awaiting physical import; procedural supernatural design remains acceptable for 03:17-only effects.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, pending recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
