# The 03:17 Customer — Production Roadmap

## Current overall progress: ~54%

Gate A is reached. M7 is complete in-repository; the latest real QA confirmed that the 03:17 customer is absent from CCTV while visible directly. M8 audio-quality work is now well underway.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%) — COMPLETE
- [ ] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix and spatial audio (6%) — IN PROGRESS (~55% of milestone)
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

## M8 implemented
- Layered refrigerator/compressor ambience with harmonics, slow load modulation and subtle vibration.
- Fluorescent ballast/electrical layer with harmonic flutter.
- Procedural player footsteps with separate walking/running cadence and strength.
- Entrance/customer arrival chime triggered by a new active customer.
- Customer exit/door-close transient.
- Scanner transient tied to scanned item count.
- Payment/receipt-printer style event when a transaction clears.
- CCTV-open static burst plus louder surveillance electrical bed.
- Dedicated 03:17 low-frequency sting with beating/hiss texture.
- Event audio lives in a separate M8 system so older stable prototype audio can be removed/rebalanced later without rewriting gameplay.

## Remaining M8 tasks
1. Add spatial customer footsteps/approach cues so visitors can be heard before they reach the register.
2. Add intermittent CCTV interference driven by signal state rather than only when CCTV opens.
3. Refine 03:17 sound sequence: brief electrical dropout, entrance chime contradiction and directional cue from the service-door side.
4. Reduce overlap with the older `audio_atmosphere.gd` prototype and establish final gain hierarchy.
5. Real Godot mix QA at 1280x720: walking/running, normal customer transaction, CCTV and full 03:17 sequence.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~55–60%, after M8 and vertical-slice QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states current milestone, estimated overall completion, completed work, blockers/risks and next major work.
