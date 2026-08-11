# The 03:17 Customer — Production Roadmap

## Current overall progress: ~52%

Gate A is reached. M7 is implementation-complete and the latest real QA confirmed that the 03:17 customer is now absent from CCTV while still visible to the player. Final CCTV safe-area polish has been added. M8 audio-quality work has started.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%) — COMPLETE, SAFE-AREA QA PENDING
- [ ] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%) — IN PROGRESS
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

## M7 final changes
- CCTV anomaly contradiction fixed with render layers: player sees visual layers 1+2; CCTV sees layer 1 only.
- Added a dedicated CCTV safe-area polish pass for 1280x720: opaque CCTV backdrop, readable left status block, inset rendered feed, separated recording stamp and bottom navigation.
- Manager note, 03:17 decision, checkout and HUD remain bilingual and 720p-aware.
- Signature bearded regular remains language-independent and uses the second procedural art pass.

## M8 current work
- Added a separate layered audio-quality system rather than overloading the original prototype audio script.
- Refrigerator/compressor ambience now has low-frequency fundamental, harmonics, slow load modulation and subtle vibration/noise.
- Fluorescent electrical ambience has a 120 Hz ballast buzz with harmonic/flutter variation.
- Player movement now drives procedural footstep foley with different cadence/strength for walking and running.
- CCTV raises the electrical layer slightly to create a distinct surveillance-space sound bed.

## Next M8 tasks
1. Entrance-door chime and customer approach/exit cues.
2. Better checkout scanner, payment and receipt-printer transients.
3. CCTV interference/noise events tied to signal state.
4. 03:17 event sequence with layered low-frequency pressure, electrical dropouts and directional cues.
5. Final balance so ambience never masks dialogue, objectives or interaction feedback.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~55–60%, after M8 and vertical-slice QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states current milestone, estimated overall completion, completed work, blockers/risks and next major work.
