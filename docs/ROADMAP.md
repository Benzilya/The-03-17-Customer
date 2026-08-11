# The 03:17 Customer — Production Roadmap

## Current overall progress: ~64%

M1–M8 are implementation-complete. M9 feature implementation is now at the QA gate: Night 2 has interactive physical evidence, CCTV contradictions, consequence feedback, bilingual decision flow, and persistence into Night 3. Final closure requires a real Godot 4.7.x playthrough in RU/EN.

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
- [ ] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%)
- [ ] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%)
- [ ] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%)
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M9 feature-complete scope
- Standalone Night 2 scene using the first-person controller.
- Four customer cases: two normal and two anomalous.
- Evidence must be inspected before the serve/refuse decision unlocks.
- Three physical evidence stations: CCTV, register/log, refrigerator reflection.
- Dedicated CCTV contradiction presentation for anomalous customers.
- Correct/wrong decision scoring and visible environmental consequences.
- Wrong calls cause verification warning, lighting instability and cumulative darkness.
- Save carryover stores correct/wrong totals, threat level, ignored-anomaly state and a Night 3 opening key.
- Russian and English strings for the Night 2 gameplay path.

## M9 QA checklist
1. Start Night 2 from Continue after a completed Night 1 save.
2. Walk to all three evidence stations and verify E interaction range/readability.
3. Confirm decision remains locked until three evidence checks are registered.
4. Test one normal customer: CCTV reports count 1 / subject detected.
5. Test one anomaly: CCTV reports count 0 / subject not detected while the customer is visibly present in-world.
6. Make one wrong decision and verify warning + lighting consequence.
7. Complete all four cases and verify `save.json` advances to night 3 with `night_2_wrong`, `threat_level`, `ignored_anomaly`, and `night_3_opening`.
8. Repeat UI/readability check at 1280x720 in Russian and English.
9. Confirm Godot debugger has no parser/runtime blocker.

## Audio note
The project is prepared to use recorded CC0 files from `assets/audio/cc0/`; synthetic ordinary SFX remain temporary fallback until selected binaries are physically imported. Supernatural 03:17 design can remain procedural where intentional.

## Next milestone: M10
Nights 3–4 will consume Night 2 threat state, introduce evidence/lore progression and make CCTV contradictions less explicit and more dangerous to interpret.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: target ~56–60%, pending final recorded-audio QA.
- Gate C — content-complete alpha: target ~85%.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
