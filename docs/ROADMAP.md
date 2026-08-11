# The 03:17 Customer — Production Roadmap

## Current overall progress: ~95%

M1–M13 are now feature-implemented. M14 is the final milestone: full-game runtime QA, legal/license audit, export presets, release packaging and release-candidate stabilization. Runtime QA debt from M8–M13 is intentionally consolidated into M14.

## Milestones
- [x] M1 — Concept, story hook, GDD, repository foundation (8%)
- [x] M2 — Main menu, settings, save bootstrap (6%)
- [x] M3 — First-person controller and procedural store blockout (6%)
- [x] M4 — Night 1 gameplay systems: customers, checkout, CCTV, 03:17 decision (8%)
- [x] M5 — First atmosphere pass: rain, lighting, audio prototype, cinematic 03:17, physical checkout props (7%)
- [x] M6 — Godot 4.7.x runtime stabilization and complete Night 1 playtest (5%) — GATE A
- [x] M7 — Visual quality/readability pass (10%)
- [x] M8 — Audio quality implementation pass (6%) — RECORDED-SFX QA DEBT
- [x] M9 — Night 2 and anomaly verification mechanics (7%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M10 — Nights 3–4, evidence/lore progression, advanced CCTV contradictions (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M11 — Nights 5–6, final 03:17 confrontation, four ending routes (10%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M12 — Save/load progression, settings completeness, subtitles/accessibility, full English/Russian localization (5%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [x] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%) — FEATURE COMPLETE / RUNTIME QA DEBT
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M13 closed scope
- Added a shared performance runtime automatically used by all Night scenes.
- Added persistent Low / Balanced / High graphics presets for the Godot Compatibility renderer.
- Low uses 75% 3D scale with MSAA disabled; Balanced uses 90% scale with 2x MSAA; High uses native scale with 4x MSAA.
- Current target is capped at 60 FPS for stable timing and compatibility-focused profiling.
- Night 1 pause menu now exposes graphics quality controls.
- Nights 2–6 receive a universal pause menu with the same quality controls.
- Restart Current Night reloads the actual current scene across the campaign.
- Player horizontal motion now accelerates/decelerates smoothly instead of snapping instantly to full speed.
- Jump is edge-triggered and no longer repeats automatically just because Space remains held after landing.
- Added coyote time and jump buffering for more forgiving first-person platform movement.
- Existing sprint/crouch/jump controls and persistent mouse sensitivity remain intact.
- M13 QA/balance specification is documented in `docs/M13_QA.md`.

## M14 final milestone
1. Run complete Nights 1–6 progression in Godot 4.7.x.
2. Regression-test RU/EN, accessibility, save recovery, bed transitions and all endings.
3. Profile Low/Balanced/High presets and fix performance/runtime blockers.
4. Physically import/finalize recorded CC0 ordinary SFX and complete license manifest.
5. Audit credits, licenses and third-party asset provenance.
6. Create/verify Windows export preset and release folder structure.
7. Fix release-blocking bugs and produce release-candidate checklist/package.

## Outstanding QA debt consolidated into M14
- Full Nights 2–6 runtime verification.
- Rest-room geometry and bed transition verification.
- M12 save/accessibility regression checks.
- M13 movement/pause/graphics runtime checks.
- Real recorded-SFX import and final mix listening pass.
- All four endings and ending-history persistence.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: implementation reached; final audio/runtime verification pending.
- Gate C — content-complete alpha: reached by feature scope.
- Gate D — release candidate: M14 target.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
