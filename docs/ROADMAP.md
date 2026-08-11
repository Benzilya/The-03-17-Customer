# The 03:17 Customer — Production Roadmap

## Current overall progress: ~56%

Gate A is reached. M7 is complete. M8 audio-quality implementation is complete in-repository and now requires one real Godot listening/runtime QA pass before Gate B vertical-slice sign-off.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass: store dressing, improved customers, bilingual Night 1 UI, manager-note modal, CCTV presentation (10%)
- [x] M8 — Audio quality pass: ambience, scanner/door/footsteps/electrical sounds, mix structure and 03:17 audio direction (6%) — IMPLEMENTATION COMPLETE / MIX QA PENDING
- [ ] M9 — Night 2 and anomaly verification mechanics (7%)
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

## M8 completion summary
- Rain is isolated in the legacy atmosphere script; duplicate legacy scanner/customer/03:17 tones were removed.
- Refrigerator/compressor ambience uses low fundamentals, harmonics, slow load modulation and vibration.
- Fluorescent electrical ambience uses harmonic buzz/flutter and changes character in CCTV mode.
- Player footsteps have separate walk/run cadence and gain.
- Customer arrival and exit drive door/chime transients.
- Scanner, payment and receipt-printer feedback is event-driven.
- CCTV has an opening burst plus intermittent signal-static events while surveillance is active.
- 03:17 now briefly ducks the normal mechanical/electrical bed, introduces low-frequency pressure, plays a deliberately wrong lower entrance chime, then returns with a second pressure pulse.
- Event gains were reduced so UI/dialogue should remain dominant.

## Required M8 sign-off test
Run Night 1 in Godot 4.7.x with headphones or normal speakers. Verify: (1) rain/hum are audible but quiet, (2) walking and running footsteps are distinct without clipping, (3) arrival chime, scanner and payment cues each fire once, (4) CCTV static is intermittent rather than continuous, (5) at 03:17 the store bed briefly falls away and the false lower chime/pressure sequence is audible, (6) debugger shows no parser/runtime blocker. Adjust gains if any layer masks dialogue.

## Next milestone: M9
Night 2 introduces anomaly verification as a repeatable mechanic: compare the customer against CCTV/store evidence, inspect contradictions, decide whether to serve/refuse, and carry consequences into later nights.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, after M8 listening QA and vertical-slice sign-off.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states current milestone, estimated overall completion, completed work, blockers/risks and next major work.
