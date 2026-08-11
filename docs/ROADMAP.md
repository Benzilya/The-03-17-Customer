# The 03:17 Customer — Production Roadmap

## Current overall progress: ~50%

Gate A is reached. M7 implementation is complete in-repository and is awaiting one final local Godot 4.7.x visual/runtime QA pass before formal sign-off.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%) — IMPLEMENTATION COMPLETE / QA PENDING
- [ ] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

## M7 completion summary
- Night 1 gameplay HUD, checkout, results and CCTV have EN/RU presentation.
- Manager note now opens in a dedicated centered modal sized for 1280x720 instead of overflowing through the lower HUD.
- 03:17 decision modal was tightened for 720p readability.
- Signature bearded regular is selected by a language-independent character style ID.
- Signature regular received a second procedural art pass: smaller round glasses, cleaner bowler silhouette, compact beard mass and restrained curled moustache/side locks instead of the previous tentacle-like starburst.
- Customer wait position remains pulled back from the cashier.
- Scanner brightness and store lighting were reduced from the earlier overexposed QA build.
- CCTV camera names, states, anomaly messages and navigation are localized.

## Required M7 sign-off test
Run Night 1 at 1280x720 in Russian and verify: (1) manager note fits without touching controls/interact HUD, (2) signature regular appears at the first customer event and face remains readable, (3) CCTV buttons/status are Russian, (4) 03:17 SERVE and REFUSE panels fit, (5) debugger shows no parser/runtime blocker. If these pass, M7 is formally signed off and M8 begins.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~55–60%, after M8 and final vertical-slice QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Next milestone: M8
Build authored-feeling audio layers for rain, refrigerator hum, fluorescent buzz, entrance chime, footsteps, checkout scanner/payment, CCTV interference and the 03:17 event; then mix and spatialize them without masking dialogue/UI cues.

## Reporting format
Every development report states current milestone, estimated overall completion, completed work, blockers/risks and next major work.
