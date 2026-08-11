# The 03:17 Customer — Production Roadmap

## Current overall progress: ~51%

Gate A is reached. M7 implementation is complete in-repository and remains in final Godot 4.7.x QA. The latest QA pass found and fixed a contradiction where CCTV text reported that the 03:17 customer was absent while the rendered feed still showed the model.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%) — IMPLEMENTATION COMPLETE / FINAL QA
- [ ] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

## Latest M7 QA fixes
- Rewrote `main.gd` into strict multi-line typed GDScript after a black-screen/parser regression.
- Tightened `interactable.gd` Variant handling for Godot 4.7 warning-as-error settings.
- 03:17 customer meshes now use visual layer 2 while ordinary store geometry and regular customers use layer 1.
- Player camera explicitly sees layers 1+2.
- Rendered CCTV camera is restricted to layer 1, so the 03:17 customer remains visible in first person but should be absent from CCTV.
- CCTV text and image are now designed to tell the same story: cashier present, customer not detected/not rendered.

## M7 completion summary
- Night 1 gameplay HUD, checkout, results and CCTV have EN/RU presentation.
- Manager note uses a dedicated centered modal for 1280x720.
- 03:17 decision modal is sized for 720p readability.
- Signature bearded regular uses a language-independent style ID and has a second procedural art pass.
- Customer waiting distance, scanner brightness and store lighting were adjusted from real QA screenshots.
- CCTV camera names, states, anomaly messages and navigation are localized.

## Required M7 sign-off test
Run the current Night 1 build at 1280x720 in Russian and verify: (1) manager note fits, (2) signature regular appears normally, (3) CCTV is localized, (4) at 03:17 the anomaly is visible directly but NOT visible in the rendered CCTV feed, (5) SERVE/REFUSE UI fits, (6) debugger has no blocker. Passing these formally closes M7.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~55–60%, after M8 and vertical-slice QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Next milestone: M8
After M7 sign-off, build audio layers for rain, refrigerator hum, fluorescent buzz, entrance chime, footsteps, checkout scanner/payment, CCTV interference and the 03:17 event; then mix and spatialize them without masking dialogue/UI cues.

## Reporting format
Every development report states current milestone, estimated overall completion, completed work, blockers/risks and next major work.
