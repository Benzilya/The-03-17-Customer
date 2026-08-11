# The 03:17 Customer — Production Roadmap

## Current overall progress: ~79%

M1–M8 are implementation-complete. M9 and M10 are feature-complete but still require final Godot QA. M11 is in active development. A shared employee rest-room transition system now connects Nights 1–5 through an in-world bed instead of requiring the player to return to the main menu between shifts.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass — IMPLEMENTATION COMPLETE / RECORDED-SFX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics — FEATURE COMPLETE / GODOT QA PENDING (~95%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions — FEATURE COMPLETE / GODOT QA PENDING (~95%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes — IN PROGRESS (~45%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging

Total production milestones: 14 (M1–M14).

## Shared rest-room transition implemented
- Nights 1–5 now instantiate a small employee rest room in the rear-right area of the store.
- Room contains partition walls, bed frame/mattress/blanket/pillow, locker and a warm practical light.
- The bed is physically interactable with `E`.
- Sleeping is locked while the current shift is unfinished.
- Once the current night has written the next-night progress into `save.json`, the bed prompt changes to `SLEEP UNTIL NEXT SHIFT` / `ЛЕЧЬ СПАТЬ ДО СЛЕДУЮЩЕЙ СМЕНЫ`.
- Interaction fades the screen to black and loads the next night directly.
- Supported direct flow: Night 1 → 2 → 3 → 4 → 5 → 6.
- Main-menu Continue remains as fallback/resume behavior.

## M11 implemented so far
- Night 5 reads the identity route inherited from Night 4.
- Identity terminal requires badge, biometric and handwritten manager-log verification.
- The player's identity integrity and trusted source are persisted.
- At 03:17, The Namekeeper arrives and offers to restore the player's identity into the security system.
- Night 5 advances save progression to Night 6.
- Four Night 6 routes are generated: `anchored_self`, `voluntary_merge`, `damaged_resistance`, `lost_identity`.
- Night 6 derives four ending routes: `ending_escape`, `ending_witness`, `ending_merge`, `ending_replaced`.

## Next M11 work
1. Build the final Night 6 03:17 confrontation as an active choice sequence.
2. Implement the four ending scenes and save ending IDs.
3. Add credits/return-to-menu flow after an ending.
4. Add late-game lore explaining the entity's manipulation of recordings and identities.
5. Runtime QA the new rest room/bed transitions across Nights 1–5 plus Nights 5–6.

## Remaining QA debt
- Verify the rest-room geometry does not collide with existing store dressing in all night scenes.
- Verify bed interaction locks before shift completion and unlocks only after the save advances.
- Verify direct scene transitions preserve the correct `save.json` branch state.
- M8 recorded CC0 ordinary SFX still need physical import and listening QA.
- M9/M10/M11 need full Godot 4.7.x runtime verification in RU/EN at 1280x720.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: pending final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
