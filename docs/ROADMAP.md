# The 03:17 Customer — Production Roadmap

## Current overall progress: ~74%

M1–M8 are implementation-complete. M9 is feature-complete and awaiting final Godot QA. M10 is now feature-complete in repository scope: Nights 3–4 form a connected progression arc, Night 4 includes memory verification and a 03:17 resolution, and save routing advances into a new Night 5 scaffold. M10 still requires runtime QA before formal closure.

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
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — FEATURE COMPLETE / GODOT QA PENDING (~95%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%) — STARTED (~10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M10 implemented scope
- Night 3 consumes Night 2 threat state and branches its opening tone.
- Night 3 compares LIVE CCTV against archive footage.
- A second Night 3 case uses a physical paper/register record to break a tie when digital feeds agree.
- Night 3 completion derives the route for Night 4.
- Night 4 changes store layout and story tone based on inherited memory reliability.
- Night 4 memory station compares three sources: the player's handwritten note, LIVE CCTV and archive.
- Night 4 stores memory integrity and trusted source.
- At 03:17, the result depends on whether the player created and trusted a valid memory anchor.
- Night 4 advances save progression to Night 5 using `anchored_identity`, `uncertain_identity`, or `fractured_identity`.
- Main-menu Continue now routes Night 1 → 2 → 3 → 4 → 5.
- Current Nights 3–5 framework is bilingual RU/EN.

## M10 QA checklist
1. Enter Night 3 with at least two different inherited `threat_level` values.
2. Verify Archive Clerk source logic changes correctly with threat state.
3. Verify the second Night 3 physical-truth case cannot be resolved solely by trusting matching digital feeds.
4. Complete Night 3 and confirm `night = 4` plus `night_4_route` is written correctly.
5. In Night 4, use the memory station and choose both correct and incorrect sources in separate runs.
6. Reach 03:17 and verify the correct message/route for anchored, uncertain and fractured memory states.
7. Confirm save advances to `night = 5` and Continue opens `scenes/night5.tscn`.
8. Check 1280x720 UI in RU and EN and confirm no parser/runtime blockers.

## M11 started
- Added `scenes/night5.tscn` and `scripts/night5.gd`.
- Night 5 opening now reads `night_5_route` from Night 4 and changes the player's identity crisis accordingly.
- The next M11 mechanic will compare employee badge, biometric clock, manager records and the player's memory anchor.

## Audio note
Recorded CC0 ordinary SFX are still awaiting physical import; procedural supernatural design remains acceptable for 03:17-only effects.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, pending recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
