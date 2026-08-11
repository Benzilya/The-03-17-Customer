# The 03:17 Customer — Production Roadmap

## Current overall progress: ~90%

M1–M12 are now feature-implemented. M13 is next: performance/graphics presets, input polish, bug fixing and balancing. Runtime QA debt remains for Nights 2–6 and the final recorded-CC0 SFX import/listening pass.

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
- [ ] M13 — Performance/graphics presets, input polish, bug fixing and balancing (5%)
- [ ] M14 — Full-game QA, credits/legal/license audit, export presets and release-candidate packaging (7%)

Total production milestones: 14 (M1–M14).

## M12 closed scope
- Added save schema/version migration and validation for Nights 1–6.
- Added primary-save recovery from `save_backup.json`.
- Bed transitions now create validated recoverable checkpoints before scene changes.
- New Game resets progress/backup without erasing user preferences.
- Main-menu Continue consumes validated progress and retains legacy `save.cfg` fallback.
- Persistent settings now include master volume, fullscreen, language and mouse sensitivity.
- Accessibility settings now include transient subtitles/messages, reduced flashing and Small/Normal/Large text scale.
- Accessibility runtime is automatically injected by the shared player controller in every night scene.
- Main-menu glitch flashing respects Reduce Flashing.
- Added Reset Settings without deleting game progress.
- Added Ending Archive showing discovered endings while hiding locked ending names.
- Added RU/EN labels for all new M12 controls and ending-history presentation.
- Added `docs/M12_QA.md` with save recovery, settings, accessibility and localization test requirements.

## M13 next
1. Add graphics/performance presets appropriate for Godot Compatibility renderer.
2. Polish movement/input feel and verify crouch/jump/sprint edge cases.
3. Run parser/runtime bug-fix passes across Nights 2–6.
4. Balance timings, interaction ranges, threat feedback and late-game readability.
5. Perform recorded-SFX import/mix cleanup where binaries are available.

## Cross-milestone QA debt
- Run Nights 2–6 in Godot 4.7.x at 1280x720 in RU and EN.
- Verify all rest-room/bed transitions, save recovery paths and four endings.
- Verify M12 accessibility options in real gameplay.
- Physically import selected CC0 ordinary SFX and perform listening/mix QA.
- Fix all parser/runtime blockers before Gate D.

## Gates
- Gate A — first playable: reached.
- Gate B — polished public-facing Night 1: pending final recorded-audio QA.
- Gate C — content-complete alpha: feature scope reached.
- Gate D — release candidate: 100%.

## Reporting format
Every development report states: milestone, overall progress, milestone progress, completed work, current repository/game size, blockers/risks and next major work.
