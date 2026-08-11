# The 03:17 Customer — Production Roadmap

## Current overall progress: ~78%

M1–M8 are implementation-complete. M9 and M10 are feature-complete but still require final Godot QA. M11 is in active development: Night 5 now has identity verification plus a 03:17 true-name confrontation, and Night 6 exists with four derived ending routes ready for final-scene implementation.

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
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%) — IN PROGRESS (~45%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M11 implemented so far
- Night 5 reads the identity route inherited from Night 4.
- Identity terminal requires badge, biometric and handwritten manager-log verification.
- The player's identity integrity and trusted source are persisted.
- At 03:17, The Namekeeper arrives and offers to restore the player's identity into the security system.
- The player chooses between preserving the paper identity anchor or allowing the system to define them.
- Night 5 advances save progression to Night 6.
- Four Night 6 state routes are generated: `anchored_self`, `voluntary_merge`, `damaged_resistance`, `lost_identity`.
- Night 6 scaffold derives one of four ending routes from memory integrity, identity integrity, the 03:17 paper/system choice and inherited threat level:
  - `ending_escape`
  - `ending_witness`
  - `ending_merge`
  - `ending_replaced`
- Main-menu Continue routes through Night 6.
- Current Night 5/6 framework has RU/EN presentation.

## Next M11 work
1. Build the final Night 6 03:17 confrontation as an active choice sequence rather than only a route scaffold.
2. Implement the four ending scenes and save ending IDs.
3. Add credits/return-to-menu flow after an ending.
4. Add late-game lore that reveals what the 03:17 entity has been doing to recordings and identities.
5. Runtime QA Nights 5–6 and regression QA Nights 2–4.

## Remaining cross-milestone QA debt
- M8 recorded CC0 ordinary SFX still need physical import and listening QA.
- M9/M10 need full Godot 4.7.x runtime verification in RU/EN at 1280x720.
- M11 will require the same runtime verification after the ending scenes exist.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: pending final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
