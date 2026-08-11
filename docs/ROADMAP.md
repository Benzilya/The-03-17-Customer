# The 03:17 Customer — Production Roadmap

## Current overall progress: ~68%

M1–M8 are implementation-complete. M9 is feature-complete and awaiting final Godot QA. M10 is in active development: Night 3 now consumes Night 2 threat state and includes the first live-CCTV versus archive contradiction mechanic.

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
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — IN PROGRESS (~35%)
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
- Lighting/opening tone changes with the player's prior mistakes.
- Archive warning, delayed camera and threatening register events are scheduled through the shift.
- First Night 3 customer: Archive Clerk / Архивист.
- Player must physically approach the security station and compare LIVE CCTV against yesterday's archive.
- The correct source depends on inherited threat state: low threat favors live feed; high threat can make the archive checksum the only trustworthy record.
- The choice is written back to `save.json` as `night_3_archive_checked` and `night_3_archive_correct` for later Night 3/4 consequences.
- Full RU/EN presentation for the archive-comparison UI.

## Next M10 work
1. Add a second Night 3 case where both feeds are internally consistent but physical store evidence breaks the tie.
2. Add Night 3 completion/save routing into Night 4.
3. Build Night 4 scene and escalation hook.
4. Add lore fragments that explain why 03:17 appears in altered recordings.
5. Godot QA for Night 3 interaction/UI and inherited threat states.

## Audio note
Recorded CC0 ordinary SFX are still awaiting physical import; procedural supernatural design remains acceptable for 03:17-only effects.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, pending recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
