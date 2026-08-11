# The 03:17 Customer — Production Roadmap

## Current overall progress: ~82%

M1–M8 are implementation-complete. M9 and M10 are feature-complete but still require final Godot QA. M11 is now close to feature completion: Night 5 carries identity state into Night 6, and Night 6 contains a playable 03:17 confrontation with four persistent ending outcomes.

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
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes — IN PROGRESS (~80%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging

Total production milestones: 14 (M1–M14).

## Shared rest-room transition implemented
- Nights 1–5 instantiate an employee rest room in the rear-right area of the store.
- Bed interaction with `E` is locked until the current night has saved progression.
- Sleeping fades to black and loads the next night directly.
- Supported direct flow: Night 1 → 2 → 3 → 4 → 5 → 6.
- Main-menu Continue remains fallback/resume behavior.

## M11 implemented
- Night 5 reads inherited identity state from Night 4.
- Identity terminal compares employee badge, biometric record and handwritten manager log.
- The player's identity integrity and trusted source are persisted.
- At 03:17, The Namekeeper arrives and forces a paper-versus-system identity choice.
- Night 5 advances progression to Night 6 with `anchored_self`, `voluntary_merge`, `damaged_resistance`, or `lost_identity`.
- Night 6 begins from that inherited route and reaches a new active 03:17 finale.
- Final customer speaks with the player's voice and states that only one version can leave the store.
- Player chooses one final action: leave with the paper record, broadcast evidence outside, or accept the system's version.
- Final outcome combines the last choice with memory integrity, identity integrity, paper choice and inherited threat.
- Four ending scenes are implemented in RU/EN:
  - `ending_escape` — player leaves with identity intact; store later closes, but 03:17 calls continue.
  - `ending_witness` — evidence escapes the store; player becomes a witness for other 03:17 cases.
  - `ending_merge` — player merges with the security system and becomes the permanent night clerk.
  - `ending_replaced` — the player's reflection/identity remains behind while official records erase them.
- Ending ID, final choice, completion flag and `unlocked_endings` collection are persisted in `save.json`.
- Ending screen supports Replay Night 6 and Return to Main Menu.

## M11 remaining
1. Runtime QA the final 03:17 timing, customer staging and ending UI at 1280x720 in RU/EN.
2. Add final late-game lore text/visual polish around the entity's relationship to the 417-day recording loop.
3. Regression-test the Night 5 bed transition into Night 6.
4. Formal M11 sign-off after Godot runtime verification.

## Remaining QA debt
- Verify rest-room geometry does not collide with store dressing in Nights 1–5.
- Verify bed interaction locks before shift completion and unlocks after save progression.
- Verify direct transitions preserve `save.json` branch state.
- M8 recorded CC0 ordinary SFX still need physical import and listening QA.
- M9/M10/M11 need full Godot 4.7.x runtime verification in RU/EN at 1280x720.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: pending final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
